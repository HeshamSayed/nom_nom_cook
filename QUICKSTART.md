# Quick Start Guide - Cookpad Egypt

Get up and running in 5 minutes!

## Prerequisites

- Python 3.10+
- Flutter 3.0+
- Git

## Backend Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/nom_nom_cook.git
cd nom_nom_cook/backend

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run migrations
python manage.py migrate

# 5. Create superuser
python manage.py createsuperuser

# 6. Start development server
python manage.py runserver
```

**Backend is now running at:** `http://localhost:8000`

**Admin panel:** `http://localhost:8000/admin`

**API docs:** `http://localhost:8000/api/docs/`

## Flutter App Quick Start

```bash
# 1. Navigate to Flutter app
cd flutter_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

**That's it!** Your Cookpad Egypt app is now running.

## Default Credentials

Use the superuser you created during setup.

## Next Steps

1. Create some categories in the admin panel
2. Add common Egyptian ingredients
3. Create your first recipe
4. Test the mobile app

## Common Issues

### Port already in use
```bash
python manage.py runserver 8001
```

### Database locked
```bash
rm db.sqlite3
python manage.py migrate
```

### Flutter packages not found
```bash
flutter pub get
flutter clean
flutter pub get
```

## Learn More

- [Full Documentation](README.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Deployment Guide](DEPLOYMENT.md)

## Support

Having issues? Check the [README.md](README.md) or open an issue on GitHub.
