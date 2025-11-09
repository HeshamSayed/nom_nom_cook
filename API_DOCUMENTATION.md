# API Documentation - Cookpad Egypt

## Base URL
```
Development: http://localhost:8000/api/v1
Production: https://api.cookpad-egypt.com/api/v1
```

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <access_token>
```

### Obtaining Tokens

**Login**
```http
POST /auth/login/
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "access": "eyJ0eXAiOiJKV1...",
  "refresh": "eyJ0eXAiOiJKV1...",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "user@example.com",
    ...
  }
}
```

**Refresh Token**
```http
POST /auth/token/refresh/
Content-Type: application/json

{
  "refresh": "eyJ0eXAiOiJKV1..."
}

Response:
{
  "access": "eyJ0eXAiOiJKV1..."
}
```

## Endpoints

### Users

#### Register
```http
POST /auth/users/
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePassword123",
  "password_confirm": "SecurePassword123",
  "preferred_language": "ar"
}

Response: 201 Created
{
  "user": {...},
  "tokens": {
    "access": "...",
    "refresh": "..."
  }
}
```

#### Get Current User
```http
GET /auth/users/me/
Authorization: Bearer <token>

Response: 200 OK
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "is_premium": false,
  "followers_count": 42,
  "following_count": 58,
  "recipes_count": 12
}
```

#### Update Profile
```http
PATCH /auth/users/me/
Authorization: Bearer <token>
Content-Type: application/json

{
  "bio": "Love cooking Egyptian food!",
  "location": "Cairo, Egypt"
}

Response: 200 OK
```

#### Follow User
```http
POST /auth/users/{user_id}/follow/
Authorization: Bearer <token>

Response: 201 Created
{
  "message": "Successfully followed user"
}
```

### Recipes

#### List Recipes
```http
GET /recipes/recipes/?category=1&difficulty=easy&is_vegan=true
Authorization: Bearer <token> (optional)

Query Parameters:
- category: int (category ID)
- difficulty: string (easy, medium, hard)
- is_vegan: boolean
- is_vegetarian: boolean
- is_gluten_free: boolean
- is_halal: boolean
- prep_time_max: int (minutes)
- search: string
- page: int

Response: 200 OK
{
  "count": 100,
  "next": "http://...?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "Koshari",
      "title_ar": "كشري",
      "description": "Traditional Egyptian street food",
      "author": {...},
      "category": {...},
      "main_image": "http://...",
      "prep_time": 20,
      "cook_time": 30,
      "servings": 4,
      "difficulty": "medium",
      "rating_average": 4.5,
      "likes_count": 245,
      "is_liked": false,
      "is_saved": false
    }
  ]
}
```

#### Get Recipe Details
```http
GET /recipes/recipes/{id}/
Authorization: Bearer <token> (optional)

Response: 200 OK
{
  "id": 1,
  "title": "Koshari",
  "description": "...",
  "author": {...},
  "category": {...},
  "recipe_ingredients": [
    {
      "id": 1,
      "ingredient": {
        "id": 1,
        "name": "Rice",
        "name_ar": "أرز"
      },
      "quantity": "2",
      "unit": "cups"
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "Cook the rice...",
      "instruction_ar": "اطبخ الأرز...",
      "image": "http://...",
      "duration": 15
    }
  ],
  "images": [...],
  "ratings": [...],
  "cooksnaps": [...]
}
```

#### Create Recipe
```http
POST /recipes/recipes/
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My Molokhia Recipe",
  "title_ar": "وصفة الملوخية",
  "description": "Family recipe for molokhia",
  "category": 1,
  "tags": ["egyptian", "traditional", "molokhia"],
  "prep_time": 15,
  "cook_time": 45,
  "servings": 6,
  "difficulty": "medium",
  "is_vegan": false,
  "is_vegetarian": true,
  "is_halal": true,
  "main_image": "base64_or_url",
  "ingredients": [
    {
      "ingredient_id": 5,
      "quantity": "500",
      "unit": "grams",
      "order": 1
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "Clean the molokhia...",
      "instruction_ar": "نظف الملوخية..."
    }
  ]
}

Response: 201 Created
```

#### Like Recipe
```http
POST /recipes/recipes/{id}/like/
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Recipe liked successfully"
}
```

#### Save Recipe
```http
POST /recipes/recipes/{id}/save/
Authorization: Bearer <token>
Content-Type: application/json

{
  "folder_id": 3,  // optional
  "notes": "Try with less garlic"
}

Response: 201 Created
```

#### Rate Recipe
```http
POST /recipes/recipes/{id}/rate/
Authorization: Bearer <token>
Content-Type: application/json

{
  "rating": 5,
  "review": "Delicious! Best molokhia I've made"
}

Response: 200 OK
```

#### Featured Recipes
```http
GET /recipes/recipes/featured/

Response: 200 OK
[...]
```

#### Popular Recipes (Premium Only)
```http
GET /recipes/recipes/popular/
Authorization: Bearer <token>

Response: 200 OK (if premium) or 403 Forbidden
```

#### Ramadan Recipes
```http
GET /recipes/recipes/ramadan/

Response: 200 OK
```

### Categories

#### List Categories
```http
GET /recipes/categories/

Response: 200 OK
[
  {
    "id": 1,
    "name": "Egyptian Cuisine",
    "name_ar": "المطبخ المصري",
    "slug": "egyptian-cuisine",
    "icon": "http://..."
  }
]
```

### Ingredients

#### List Ingredients
```http
GET /recipes/ingredients/?search=rice

Response: 200 OK
```

#### Common Ingredients
```http
GET /recipes/ingredients/common/

Response: 200 OK
```

### Meal Planning

#### List Meal Plans
```http
GET /recipes/meal-plans/?start_date=2024-01-01&end_date=2024-01-07
Authorization: Bearer <token>

Response: 200 OK
```

#### Create Meal Plan
```http
POST /recipes/meal-plans/
Authorization: Bearer <token>
Content-Type: application/json

{
  "recipe_id": 5,
  "date": "2024-01-15",
  "meal_type": "iftar",
  "servings": 4,
  "notes": "For Ramadan"
}

Response: 201 Created
```

#### Generate Shopping List
```http
POST /recipes/meal-plans/generate_shopping_list/
Authorization: Bearer <token>
Content-Type: application/json

{
  "start_date": "2024-01-15",
  "end_date": "2024-01-21"
}

Response: 201 Created
{
  "id": 1,
  "name": "Shopping List 2024-01-15 to 2024-01-21",
  "items": [
    {
      "ingredient": {...},
      "quantity": "2 + 3",
      "unit": "cups",
      "is_purchased": false
    }
  ]
}
```

### Shopping Lists

#### List Shopping Lists
```http
GET /recipes/shopping-lists/
Authorization: Bearer <token>

Response: 200 OK
```

#### Add Item to Shopping List
```http
POST /recipes/shopping-lists/{id}/add_item/
Authorization: Bearer <token>
Content-Type: application/json

{
  "ingredient_id": 10,
  "quantity": "500",
  "unit": "grams"
}

Response: 201 Created
```

#### Toggle Item Purchased Status
```http
PATCH /recipes/shopping-lists/{id}/toggle_item/
Authorization: Bearer <token>
Content-Type: application/json

{
  "item_id": 15
}

Response: 200 OK
```

### Social

#### List Comments
```http
GET /social/comments/?recipe_id=5

Response: 200 OK
```

#### Create Comment
```http
POST /social/comments/
Authorization: Bearer <token>
Content-Type: application/json

{
  "recipe": 5,
  "text": "This looks delicious!",
  "parent": null  // or comment_id for reply
}

Response: 201 Created
```

#### Notifications
```http
GET /social/notifications/
Authorization: Bearer <token>

Response: 200 OK
```

#### Unread Notifications
```http
GET /social/notifications/unread/
Authorization: Bearer <token>

Response: 200 OK
```

#### Mark Notification as Read
```http
POST /social/notifications/{id}/mark_as_read/
Authorization: Bearer <token>

Response: 200 OK
```

### Subscriptions

#### List Plans
```http
GET /subscriptions/plans/

Response: 200 OK
[
  {
    "id": 1,
    "name": "Individual Monthly",
    "name_ar": "شهري فردي",
    "price_egp": "49.00",
    "billing_period": "monthly",
    "max_saved_recipes": 3000,
    "has_advanced_search": true,
    "is_ad_free": true
  }
]
```

#### Current Subscription
```http
GET /subscriptions/subscriptions/current/
Authorization: Bearer <token>

Response: 200 OK or 404 Not Found
```

#### Subscribe
```http
POST /subscriptions/subscriptions/subscribe/
Authorization: Bearer <token>
Content-Type: application/json

{
  "plan_id": 1,
  "coupon_code": "RAMADAN2024"  // optional
}

Response: 201 Created
{
  "subscription": {...},
  "payment": {...}
}
```

#### Cancel Subscription
```http
POST /subscriptions/subscriptions/{id}/cancel/
Authorization: Bearer <token>

Response: 200 OK
```

### Chat

#### List Chat Rooms
```http
GET /chat/rooms/
Authorization: Bearer <token>

Response: 200 OK
```

#### Create Direct Chat
```http
POST /chat/rooms/create_direct/
Authorization: Bearer <token>
Content-Type: application/json

{
  "user_id": 5
}

Response: 200 OK or 201 Created
```

#### List Messages
```http
GET /chat/messages/?room_id=3
Authorization: Bearer <token>

Response: 200 OK
```

#### Send Message
```http
POST /chat/messages/
Authorization: Bearer <token>
Content-Type: application/json

{
  "room": 3,
  "message_type": "text",
  "content": "Hello! Loved your recipe!"
}

Response: 201 Created
```

### WebSocket Chat

Connect to: `ws://localhost:8000/ws/chat/{room_id}/`

**Send Message:**
```json
{
  "type": "text",
  "content": "Hello!",
  "sender_id": 1
}
```

**Receive Message:**
```json
{
  "message": {
    "id": 123,
    "sender_id": 1,
    "sender_username": "john_doe",
    "message_type": "text",
    "content": "Hello!",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid input data",
  "details": {
    "email": ["Enter a valid email address."]
  }
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "error": "This feature is only available for premium users"
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "error": "An error occurred on the server"
}
```

## Rate Limiting

- Anonymous users: 100 requests/hour
- Authenticated users: 1000 requests/hour
- Premium users: 5000 requests/hour

## Pagination

All list endpoints support pagination:

```
?page=2&page_size=20
```

Default page size: 20
Maximum page size: 100

## Filtering & Ordering

Use query parameters:

```
?ordering=-created_at  // Descending by created_at
?ordering=rating_average  // Ascending by rating
```

## Search

Full-text search available on recipe endpoints:

```
?search=molokhia
```
