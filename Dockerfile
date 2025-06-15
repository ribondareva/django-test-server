FROM python:3.9-slim

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    nginx \
    postgresql \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Установка Python-зависимостей
RUN pip install --no-cache-dir -r requirements.txt

# Настройка Nginx
RUN cp nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 5432

CMD ["sh", "-c", "service postgresql start && \
     sleep 5 && \
     su - postgres -c \"psql -c \\\"CREATE USER django WITH PASSWORD 'djangopass';\\\"\" && \
     su - postgres -c \"psql -c \\\"CREATE DATABASE djangodb OWNER django;\\\"\" && \
     python manage.py migrate && \
     echo \"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')\" | python manage.py shell && \
     python manage.py collectstatic --noinput && \
     gunicorn --bind 0.0.0.0:8000 myproject.wsgi & \
     nginx -g 'daemon off;'"]