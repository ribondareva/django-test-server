#!/bin/bash

# Инициализация и запуск PostgreSQL
if [ ! -d "/var/lib/postgresql/data" ]; then
    mkdir -p /var/lib/postgresql/data
    chown postgres:postgres /var/lib/postgresql/data
    su - postgres -c "initdb -D /var/lib/postgresql/data"
    echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf
fi

su - postgres -c "pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/logfile start"

# Ожидание запуска PostgreSQL
until pg_isready -h localhost -p 5432; do
    sleep 1
done

# Создание БД и пользователя
su - postgres -c "psql -c \"CREATE USER django WITH PASSWORD 'djangopass';\""
su - postgres -c "psql -c \"CREATE DATABASE djangodb OWNER django;\""

# Миграции Django
python manage.py migrate

# Создание суперпользователя
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python manage.py shell

# Сбор статики
python manage.py collectstatic --noinput

# Запуск Gunicorn
gunicorn --bind 0.0.0.0:8000 --workers 3 myproject.wsgi &

# Запуск Nginx
nginx -g "daemon off;"