# Cookpad Egypt - Recipe Sharing Platform

> A comprehensive recipe sharing platform for the Egyptian market, built with Django REST Framework and Flutter.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Mobile App](#mobile-app)
- [Key Features Implementation](#key-features-implementation)
- [Deployment](#deployment)
- [Contributing](#contributing)

## 🎯 Overview

Cookpad Egypt is a localized recipe-sharing platform designed specifically for the Egyptian market. It enables home cooks to share recipes, connect with other food enthusiasts, plan meals, and discover new Egyptian and international cuisines.

### Key Highlights

- **100M+ MAU globally** (Cookpad platform)
- **4M+ recipes** created by users worldwide
- **70+ countries**, 23 languages supported
- **Egyptian market focus** with localized features
- **Community-first approach** for home cooks

## ✨ Features

### Core Features

#### Recipe Management
- ✅ Create, edit, and delete recipes
- ✅ Upload recipe images and step-by-step photos
- ✅ Ingredient-based search
- ✅ Advanced filtering (dietary preferences, cuisine, difficulty)
- ✅ Recipe ratings and reviews
- ✅ CookSnaps (user-generated photos of cooked recipes)

#### Social Features
- ✅ Follow/unfollow users
- ✅ Like and save recipes
- ✅ Comment on recipes with nested replies
- ✅ Real-time chat functionality
- ✅ Notifications system
- ✅ User profiles with statistics

#### Meal Planning & Shopping
- ✅ Weekly meal planning (Cookplan)
- ✅ Automatic shopping list generation
- ✅ Recipe folders and organization
- ✅ Offline recipe access

#### Premium Features
- ✅ Ad-free experience
- ✅ Unlimited recipe saves (up to 3000)
- ✅ Popular recipes priority
- ✅ Nutritional information
- ✅ Advanced search filters
- ✅ Exclusive content access

#### Egyptian Market Specific
- ✅ Arabic/English bilingual support
- ✅ Ramadan special collections (Iftar/Suhoor)
- ✅ Egyptian cuisine categories (Koshari, Molokhia, etc.)
- ✅ Local ingredient database
- ✅ Halal recipes by default

## 🛠 Technology Stack

### Backend
- **Framework**: Django 4.2.7
- **API**: Django REST Framework 3.14.0
- **Authentication**: JWT (Simple JWT)
- **Database**: PostgreSQL (production) / SQLite (development)
- **Caching**: Redis
- **Task Queue**: Celery
- **Real-time**: Django Channels + WebSockets
- **Search**: Elasticsearch (optional)
- **Payments**: Stripe Integration
- **Storage**: AWS S3 (optional) / Local storage

### Mobile App
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Networking**: HTTP / Dio
- **Local Storage**: Hive + SharedPreferences
- **Authentication**: flutter_secure_storage
- **Image Handling**: image_picker, cached_network_image
- **Internationalization**: flutter_localizations

### DevOps & Tools
- **Server**: Gunicorn + Nginx
- **API Documentation**: drf-spectacular (OpenAPI/Swagger)
- **Version Control**: Git
- **Environment**: python-decouple

## 📁 Project Structure

```
nom_nom_cook/
├── backend/                      # Django backend
│   ├── cookpad_egypt/           # Project settings
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── wsgi.py
│   │   ├── asgi.py
│   │   └── celery.py
│   ├── apps/                    # Django apps
│   │   ├── users/               # User authentication & profiles
│   │   │   ├── models.py        # User, UserPreferences, Follow
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   └── admin.py
│   │   ├── recipes/             # Recipe management
│   │   │   ├── models.py        # Recipe, Ingredient, Category, etc.
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   ├── filters.py
│   │   │   └── admin.py
│   │   ├── social/              # Social interactions
│   │   │   ├── models.py        # Like, Comment, Notification, Report
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   └── admin.py
│   │   ├── subscriptions/       # Premium subscriptions
│   │   │   ├── models.py        # SubscriptionPlan, Subscription, Payment
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   └── admin.py
│   │   └── chat/                # Real-time chat
│   │       ├── models.py        # ChatRoom, Message
│   │       ├── serializers.py
│   │       ├── views.py
│   │       ├── urls.py
│   │       ├── consumers.py
│   │       ├── routing.py
│   │       └── admin.py
│   ├── manage.py
│   └── requirements.txt
│
├── flutter_app/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                # App-wide configurations
│   │   │   ├── app_constants.dart
│   │   │   └── theme.dart
│   │   ├── models/              # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── recipe_model.dart
│   │   │   └── ...
│   │   ├── services/            # API services
│   │   │   ├── api_service.dart
│   │   │   └── ...
│   │   ├── providers/           # State management
│   │   │   ├── auth_provider.dart
│   │   │   ├── recipe_provider.dart
│   │   │   └── ...
│   │   ├── screens/             # UI screens
│   │   │   ├── splash_screen.dart
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── recipe/
│   │   │   └── ...
│   │   ├── widgets/             # Reusable widgets
│   │   └── utils/               # Utilities
│   ├── pubspec.yaml
│   └── ...
│
├── .gitignore
└── README.md
```

## 🚀 Installation

### Prerequisites

- Python 3.10+
- PostgreSQL 13+ (for production)
- Redis 6+ (for caching and Celery)
- Flutter 3.0+
- Node.js (optional, for frontend tooling)

### Backend Setup

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/nom_nom_cook.git
cd nom_nom_cook
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment variables**
```bash
cd backend
cp .env.example .env
# Edit .env with your configuration
```

5. **Run migrations**
```bash
python manage.py makemigrations
python manage.py migrate
```

6. **Create superuser**
```bash
python manage.py createsuperuser
```

7. **Load initial data (optional)**
```bash
# Create categories, common ingredients
python manage.py loaddata fixtures/initial_data.json
```

### Flutter App Setup

1. **Navigate to Flutter app**
```bash
cd flutter_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
Edit `lib/core/app_constants.dart` and update `baseUrl` to your backend URL.

4. **Run the app**
```bash
flutter run
```

## ⚙️ Configuration

### Backend Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# Django Settings
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=cookpad_egypt
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432

# Redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0

# Email
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Stripe (for payments)
STRIPE_PUBLIC_KEY=pk_test_your_key
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret

# AWS S3 (optional)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_STORAGE_BUCKET_NAME=your_bucket
AWS_S3_REGION_NAME=us-east-1
```

## 🏃 Running the Application

### Development Mode

#### Backend

1. **Start Django development server**
```bash
cd backend
python manage.py runserver
```
API will be available at: `http://localhost:8000`

2. **Start Celery worker** (in a new terminal)
```bash
cd backend
celery -A cookpad_egypt worker -l info
```

3. **Start Celery beat** (for scheduled tasks, in another terminal)
```bash
cd backend
celery -A cookpad_egypt beat -l info
```

4. **Start Channels/WebSocket** (for real-time chat)
```bash
cd backend
daphne -b 0.0.0.0 -p 8000 cookpad_egypt.asgi:application
```

#### Flutter App

```bash
cd flutter_app
flutter run
```

### Production Mode

See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment instructions.

## 📚 API Documentation

### API Endpoints

#### Authentication
- `POST /api/v1/auth/login/` - User login
- `POST /api/v1/auth/users/` - User registration
- `POST /api/v1/auth/token/refresh/` - Refresh JWT token
- `GET /api/v1/auth/users/me/` - Get current user
- `PUT /api/v1/auth/users/me/` - Update current user

#### Recipes
- `GET /api/v1/recipes/recipes/` - List recipes
- `POST /api/v1/recipes/recipes/` - Create recipe
- `GET /api/v1/recipes/recipes/{id}/` - Get recipe details
- `PUT /api/v1/recipes/recipes/{id}/` - Update recipe
- `DELETE /api/v1/recipes/recipes/{id}/` - Delete recipe
- `POST /api/v1/recipes/recipes/{id}/like/` - Like recipe
- `POST /api/v1/recipes/recipes/{id}/save/` - Save recipe
- `POST /api/v1/recipes/recipes/{id}/rate/` - Rate recipe
- `GET /api/v1/recipes/recipes/featured/` - Featured recipes
- `GET /api/v1/recipes/recipes/popular/` - Popular recipes (Premium)
- `GET /api/v1/recipes/recipes/ramadan/` - Ramadan recipes

#### Social
- `GET /api/v1/social/comments/` - List comments
- `POST /api/v1/social/comments/` - Create comment
- `GET /api/v1/social/notifications/` - List notifications
- `GET /api/v1/social/notifications/unread/` - Unread notifications
- `POST /api/v1/social/notifications/{id}/mark_as_read/` - Mark as read

#### Subscriptions
- `GET /api/v1/subscriptions/plans/` - List subscription plans
- `GET /api/v1/subscriptions/subscriptions/current/` - Current subscription
- `POST /api/v1/subscriptions/subscriptions/subscribe/` - Create subscription
- `POST /api/v1/subscriptions/subscriptions/{id}/cancel/` - Cancel subscription

### Interactive API Documentation

Visit `http://localhost:8000/api/docs/` for interactive Swagger UI documentation.

### Authentication

All authenticated endpoints require JWT token in the Authorization header:

```
Authorization: Bearer <your_access_token>
```

## 📱 Mobile App

### Features

1. **Authentication**
   - Login/Register with email
   - JWT token management
   - Automatic token refresh

2. **Recipe Discovery**
   - Browse recipes feed
   - Search by ingredients, name, tags
   - Filter by dietary preferences, cuisine, difficulty
   - View recipe details with ingredients and steps

3. **Social Interaction**
   - Follow/unfollow users
   - Like and save recipes
   - Comment on recipes
   - Share cooksnaps

4. **Meal Planning**
   - Plan weekly meals
   - Generate shopping lists
   - Track cooked meals

5. **Profile**
   - View/edit profile
   - Recipe collection
   - Followers/following
   - Saved recipes

### Screenshots

_Add screenshots here_

## 🎨 Key Features Implementation

### Ingredient-Based Search

```python
# Backend: recipes/views.py
@action(detail=False, methods=['get'])
def search_by_ingredients(self, request):
    ingredients = request.query_params.get('ingredients', '').split(',')
    recipes = Recipe.objects.filter(
        recipe_ingredients__ingredient__name__in=ingredients
    ).distinct()
    return Response(RecipeListSerializer(recipes, many=True).data)
```

### Ramadan Special Collections

```python
# Backend: Automatic filtering
recipes = Recipe.objects.filter(
    Q(tags__contains=['ramadan']) |
    Q(tags__contains=['iftar']) |
    Q(tags__contains=['suhoor'])
)
```

### Premium Subscription Model

```python
# EGP 49-79/month individual plan
# EGP 149/month family plan (up to 5 members)
# Features: Unlimited saves, ad-free, popular recipes, nutritional info
```

### Real-time Chat

```python
# Backend: WebSocket consumer
# Flutter: web_socket_channel for real-time messaging
```

### Offline Functionality

```dart
// Flutter: Hive for local storage
await Hive.openBox('recipes');
await Hive.openBox('saved_recipes');
await Hive.openBox('meal_plans');
```

## 🚢 Deployment

### Backend Deployment (Production)

#### Using Docker

```bash
# Build image
docker build -t cookpad-egypt-backend .

# Run container
docker run -d -p 8000:8000 \
  --env-file .env \
  --name cookpad-backend \
  cookpad-egypt-backend
```

#### Manual Deployment

1. **Install dependencies**
```bash
pip install -r requirements.txt
pip install gunicorn
```

2. **Collect static files**
```bash
python manage.py collectstatic --noinput
```

3. **Run migrations**
```bash
python manage.py migrate
```

4. **Start Gunicorn**
```bash
gunicorn cookpad_egypt.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 4 \
  --timeout 120
```

5. **Configure Nginx** (reverse proxy)
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /static/ {
        alias /path/to/staticfiles/;
    }

    location /media/ {
        alias /path/to/media/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Flutter App Deployment

#### Android

```bash
flutter build apk --release
# APK located at: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS

```bash
flutter build ios --release
# Open Xcode and archive for App Store
```

## 🧪 Testing

### Backend Tests

```bash
cd backend
python manage.py test
```

### Flutter Tests

```bash
cd flutter_app
flutter test
```

## 📊 Database Schema

Key models and relationships:

- **User** → has many → **Recipes**
- **User** → follows → **User** (Many-to-Many)
- **Recipe** → belongs to → **Category**
- **Recipe** → has many → **RecipeIngredients**
- **Recipe** → has many → **RecipeSteps**
- **Recipe** → has many → **Comments**
- **User** → has one → **UserPreferences**
- **User** → has many → **Subscriptions**
- **Recipe** → saved by → **User** (Many-to-Many through SavedRecipe)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- **Senior Product Manager** - Product Analysis & Strategy
- **Senior Full Stack Engineer** - Django DRF + Flutter Implementation

## 🙏 Acknowledgments

- Cookpad - Original platform inspiration
- Egyptian cooking community
- All contributors and testers

## 📞 Support

For support, email support@cookpad-egypt.com or join our community Discord.

---

**Built with ❤️ for Egyptian home cooks**
