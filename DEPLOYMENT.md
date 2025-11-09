# Deployment Guide - Cookpad Egypt

## Table of Contents
- [Production Requirements](#production-requirements)
- [Server Setup](#server-setup)
- [Database Setup](#database-setup)
- [Backend Deployment](#backend-deployment)
- [Flutter App Deployment](#flutter-app-deployment)
- [CI/CD Setup](#cicd-setup)

## Production Requirements

### Server Requirements
- Ubuntu 20.04 LTS or later
- 4GB RAM minimum (8GB recommended)
- 2 CPU cores minimum
- 50GB SSD storage
- PostgreSQL 13+
- Redis 6+
- Nginx 1.18+

### Domain & SSL
- Domain name registered
- SSL certificate (Let's Encrypt recommended)

## Server Setup

### 1. Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install Dependencies
```bash
sudo apt install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx redis-server
```

### 3. Install PostgreSQL
```bash
sudo -u postgres psql

CREATE DATABASE cookpad_egypt;
CREATE USER cookpad_user WITH PASSWORD 'your_secure_password';
ALTER ROLE cookpad_user SET client_encoding TO 'utf8';
ALTER ROLE cookpad_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE cookpad_user SET timezone TO 'Africa/Cairo';
GRANT ALL PRIVILEGES ON DATABASE cookpad_egypt TO cookpad_user;
\q
```

### 4. Configure Redis
```bash
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## Backend Deployment

### 1. Clone Repository
```bash
cd /var/www
sudo git clone https://github.com/yourusername/nom_nom_cook.git
sudo chown -R $USER:$USER nom_nom_cook
cd nom_nom_cook/backend
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn
```

### 3. Configure Environment
```bash
cp .env.example .env
nano .env
```

Update production settings:
```env
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DB_ENGINE=django.db.backends.postgresql
DB_NAME=cookpad_egypt
DB_USER=cookpad_user
DB_PASSWORD=your_secure_password
DB_HOST=localhost
DB_PORT=5432
SECRET_KEY=generate_a_secure_random_key_here
```

### 4. Run Migrations
```bash
python manage.py migrate
python manage.py collectstatic --noinput
python manage.py createsuperuser
```

### 5. Create Gunicorn Systemd Service
```bash
sudo nano /etc/systemd/system/cookpad.service
```

```ini
[Unit]
Description=Cookpad Egypt Gunicorn daemon
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/nom_nom_cook/backend
Environment="PATH=/var/www/nom_nom_cook/backend/venv/bin"
ExecStart=/var/www/nom_nom_cook/backend/venv/bin/gunicorn \
          --workers 4 \
          --bind unix:/var/www/nom_nom_cook/backend/cookpad.sock \
          --timeout 120 \
          cookpad_egypt.wsgi:application

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl start cookpad
sudo systemctl enable cookpad
```

### 6. Create Celery Systemd Service
```bash
sudo nano /etc/systemd/system/celery.service
```

```ini
[Unit]
Description=Celery Service
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/var/www/nom_nom_cook/backend
Environment="PATH=/var/www/nom_nom_cook/backend/venv/bin"
ExecStart=/var/www/nom_nom_cook/backend/venv/bin/celery -A cookpad_egypt worker --loglevel=info --detach

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl start celery
sudo systemctl enable celery
```

### 7. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/cookpad
```

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    client_max_body_size 10M;

    location = /favicon.ico { access_log off; log_not_found off; }

    location /static/ {
        alias /var/www/nom_nom_cook/backend/staticfiles/;
    }

    location /media/ {
        alias /var/www/nom_nom_cook/backend/media/;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/var/www/nom_nom_cook/backend/cookpad.sock;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    # WebSocket support for chat
    location /ws/ {
        proxy_pass http://unix:/var/www/nom_nom_cook/backend/cookpad.sock;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/cookpad /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
```

### 8. Setup SSL with Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
sudo systemctl reload nginx
```

### 9. Setup Firewall
```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
```

## Database Backup

### Automated Daily Backups
```bash
sudo nano /usr/local/bin/backup-cookpad-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/cookpad"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p $BACKUP_DIR

pg_dump -U cookpad_user cookpad_egypt | gzip > $BACKUP_DIR/cookpad_$TIMESTAMP.sql.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -name "cookpad_*.sql.gz" -mtime +7 -delete
```

```bash
sudo chmod +x /usr/local/bin/backup-cookpad-db.sh
sudo crontab -e
```

Add:
```
0 2 * * * /usr/local/bin/backup-cookpad-db.sh
```

## Flutter App Deployment

### Android

1. **Update API endpoint**
```dart
// lib/core/app_constants.dart
static const String baseUrl = 'https://api.your-domain.com';
```

2. **Configure app signing**

Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=cookpad
storeFile=/path/to/keystore.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

3. **Build APK**
```bash
flutter build apk --release
```

4. **Build App Bundle for Google Play**
```bash
flutter build appbundle --release
```

### iOS

1. **Update API endpoint** (same as Android)

2. **Configure in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Update bundle identifier
   - Configure signing & capabilities
   - Set deployment target

3. **Build for release**
```bash
flutter build ios --release
```

4. **Archive and upload to App Store**
   - Open Xcode
   - Product → Archive
   - Distribute App → App Store Connect

## Monitoring & Maintenance

### 1. Setup Logging
```bash
sudo mkdir -p /var/log/cookpad
sudo chown www-data:www-data /var/log/cookpad
```

Update `settings.py`:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/var/log/cookpad/django.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'ERROR',
            'propagate': True,
        },
    },
}
```

### 2. Monitor Services
```bash
sudo systemctl status cookpad
sudo systemctl status celery
sudo systemctl status nginx
sudo systemctl status postgresql
sudo systemctl status redis-server
```

### 3. View Logs
```bash
sudo journalctl -u cookpad -f
sudo journalctl -u celery -f
tail -f /var/log/nginx/error.log
```

## Performance Optimization

### 1. Enable Gzip Compression
Add to Nginx config:
```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
```

### 2. Setup CDN
- Configure AWS CloudFront or Cloudflare
- Point media and static files to CDN

### 3. Database Optimization
```sql
-- Create indexes
CREATE INDEX idx_recipe_category ON recipes_recipe(category_id);
CREATE INDEX idx_recipe_author ON recipes_recipe(author_id);
CREATE INDEX idx_recipe_rating ON recipes_recipe(rating_average);
```

### 4. Redis Caching
Update `settings.py`:
```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
```

## Scaling

### Horizontal Scaling
1. Setup load balancer (AWS ELB, Nginx)
2. Deploy multiple Gunicorn instances
3. Use external database (AWS RDS)
4. Use external Redis (AWS ElastiCache)
5. Use S3 for media storage

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize Gunicorn workers: `workers = (2 * CPU_COUNT) + 1`

## Troubleshooting

### Check service status
```bash
sudo systemctl status cookpad
sudo systemctl status celery
```

### Restart services
```bash
sudo systemctl restart cookpad
sudo systemctl restart celery
sudo systemctl restart nginx
```

### Database connection issues
```bash
sudo -u postgres psql
\l  # List databases
\du  # List users
```

### Permission issues
```bash
sudo chown -R www-data:www-data /var/www/nom_nom_cook
sudo chmod -R 755 /var/www/nom_nom_cook
```
