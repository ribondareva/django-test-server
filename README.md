## Тестовое задание
Инструкция для тестируемых:
1. Установите Docker
2. Загрузите образ из DockerHub
   ```bash
   docker run -p 80:80 -p 5432:5432 вашлогин/django-test-server
   ```
4. Запустите команду:
   ```bash
   docker run -p 80:80 -p 5432:5432 ribondareva/django-test-server
   ```
5. Откройте http://localhost и http://localhost/admin
