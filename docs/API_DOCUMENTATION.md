# PulseNews API Documentation

## Overview

PulseNews integrates with multiple external APIs and provides its own RESTful API for user data management. This document outlines all API endpoints, data structures, and integration patterns.

## External APIs

### NewsAPI.org Integration

**Base URL:** `https://newsapi.org`

**Authentication:** API Key via X-Api-Key header

#### Endpoints

##### Get Top Headlines
```http
GET /v2/top-headlines
```

**Parameters:**
- `country` (string, required): ISO 3166-1 alpha-2 country code
- `category` (string, optional): Category filter (business, entertainment, general, health, science, sports, technology)
- `pageSize` (integer, optional): Number of results per page (max 100)
- `page` (integer, optional): Page number for pagination

**Response:**
```json
{
  "status": "ok",
  "totalResults": 38,
  "articles": [
    {
      "source": {
        "id": "techcrunch",
        "name": "TechCrunch"
      },
      "author": "Author Name",
      "title": "Article Title",
      "description": "Article description...",
      "url": "https://example.com/article",
      "urlToImage": "https://example.com/image.jpg",
      "publishedAt": "2024-01-01T12:00:00Z",
      "content": "Article content..."
    }
  ]
}
```

##### Search Everything
```http
GET /v2/everything
```

**Parameters:**
- `q` (string, required): Search query
- `searchIn` (string, optional): Fields to search in (title, description, content)
- `sources` (string, optional): Comma-separated list of source IDs
- `domains` (string, optional): Comma-separated list of domains
- `excludeDomains` (string, optional): Domains to exclude
- `from` (string, optional): ISO 8601 date format
- `to` (string, optional): ISO 8601 date format
- `language` (string, optional): ISO 639-1 language code
- `sortBy` (string, optional): relevancy, popularity, publishedAt
- `pageSize` (integer, optional): Number of results per page
- `page` (integer, optional): Page number

## Internal API

**Base URL:** `https://api.pulsenews.app`

**Authentication:** Bearer token (JWT)

### Authentication Endpoints

#### Sign In
```http
POST /auth/signin
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "hashed_password",
  "deviceInfo": {
    "platform": "ios",
    "version": "1.0.0",
    "deviceId": "unique_device_id"
  }
}
```

**Response:**
```json
{
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "displayName": "User Name",
    "isEmailVerified": true,
    "isBiometricEnabled": false,
    "createdAt": "2024-01-01T00:00:00Z",
    "lastLoginAt": "2024-01-01T12:00:00Z",
    "preferences": {
      "theme": "system",
      "language": "en",
      "followedCategories": ["technology", "business"],
      "followedSources": ["techcrunch"],
      "notificationsEnabled": true
    }
  },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "expiresAt": "2024-01-01T12:00:00Z"
}
```

#### Sign Up
```http
POST /auth/signup
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "hashed_password",
  "displayName": "User Name",
  "deviceInfo": {
    "platform": "ios",
    "version": "1.0.0",
    "deviceId": "unique_device_id"
  }
}
```

#### Refresh Token
```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "jwt_refresh_token"
}
```

#### Sign Out
```http
POST /auth/signout
```

**Request Body:**
```json
{
  "refreshToken": "jwt_refresh_token"
}
```

#### Reset Password
```http
POST /auth/reset-password
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

### User Management Endpoints

#### Get User Profile
```http
GET /users/me
```

**Response:**
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoUrl": "https://example.com/avatar.jpg",
  "bio": "User bio",
  "isEmailVerified": true,
  "isBiometricEnabled": false,
  "linkedProviders": ["google", "apple"],
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLoginAt": "2024-01-01T12:00:00Z",
  "preferences": {
    "theme": "system",
    "language": "en",
    "followedCategories": ["technology", "business"],
    "followedSources": ["techcrunch"],
    "notificationsEnabled": true
  }
}
```

#### Update Profile
```http
PATCH /users/me
```

**Request Body:**
```json
{
  "displayName": "Updated Name",
  "bio": "Updated bio",
  "photoUrl": "https://example.com/new-avatar.jpg"
}
```

#### Delete Account
```http
DELETE /users/me
```

### Articles Management Endpoints

#### Save Article
```http
POST /articles
```

**Request Body:**
```json
{
  "id": "article_id",
  "title": "Article Title",
  "description": "Article description",
  "url": "https://example.com/article",
  "urlToImage": "https://example.com/image.jpg",
  "sourceName": "Source Name",
  "author": "Author Name",
  "publishedAt": "2024-01-01T12:00:00Z",
  "content": "Article content",
  "categories": ["technology"],
  "isBookmarked": true,
  "bookmarkedAt": "2024-01-01T12:00:00Z",
  "isRead": false,
  "readAt": null
}
```

#### Get Saved Articles
```http
GET /articles/saved
```

**Parameters:**
- `page` (integer, optional): Page number
- `pageSize` (integer, optional): Results per page
- `sortBy` (string, optional): Sort field (bookmarkedAt, publishedAt)

#### Delete Article
```http
DELETE /articles/{articleId}
```

#### Mark Article as Read
```http
PATCH /articles/{articleId}/read
```

**Request Body:**
```json
{
  "readAt": "2024-01-01T12:00:00Z"
}
```

### Reading History Endpoints

#### Get Reading History
```http
GET /users/me/history
```

**Parameters:**
- `page` (integer, optional): Page number
- `pageSize` (integer, optional): Results per page
- `from` (string, optional): ISO 8601 date
- `to` (string, optional): ISO 8601 date

#### Clear Reading History
```http
DELETE /users/me/history
```

### Social Authentication Endpoints

#### Sign In with Social Provider
```http
POST /auth/social/{provider}
```

**Parameters:**
- `provider` (string): google, facebook, twitter, apple, github

**Request Body:**
```json
{
  "provider": "google",
  "accessToken": "social_access_token",
  "deviceInfo": {
    "platform": "ios",
    "version": "1.0.0",
    "deviceId": "unique_device_id"
  }
}
```

#### Link Social Provider
```http
POST /users/me/link-social
```

**Request Body:**
```json
{
  "provider": "google",
  "accessToken": "social_access_token"
}
```

#### Unlink Social Provider
```http
DELETE /users/me/unlink-social/{provider}
```

### Synchronization Endpoints

#### Sync Changes
```http
POST /sync
```

**Request Body:**
```json
{
  "changes": [
    {
      "id": "change_id",
      "type": "save_article",
      "entityId": "article_id",
      "data": {
        "title": "Article Title"
      },
      "timestamp": "2024-01-01T12:00:00Z"
    }
  ]
}
```

#### Get Remote Changes
```http
GET /sync/changes
```

**Parameters:**
- `since` (string, optional): ISO 8601 timestamp for incremental sync

## Error Handling

### HTTP Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required or invalid
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., user already exists)
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error
- `502 Bad Gateway`: Gateway error
- `503 Service Unavailable`: Service temporarily unavailable

### Error Response Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {
      "field": "Specific error details"
    }
  }
}
```

### Common Error Codes

- `INVALID_EMAIL`: Invalid email format
- `INVALID_PASSWORD`: Password doesn't meet requirements
- `USER_NOT_FOUND`: User account not found
- `USER_EXISTS`: User account already exists
- `INVALID_TOKEN`: Invalid or expired token
- `RATE_LIMIT`: Too many requests
- `NETWORK_ERROR`: Network connectivity issue
- `SERVER_ERROR`: Internal server error

## Rate Limiting

### Limits
- **Authentication endpoints**: 5 requests per minute
- **User data endpoints**: 100 requests per minute
- **Article management**: 200 requests per minute
- **Sync endpoints**: 1000 requests per hour

### Headers
Rate limit information is included in response headers:
- `X-RateLimit-Limit`: Request limit per window
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Time when limit resets (Unix timestamp)

## Data Models

### User Model
```json
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string|null",
  "bio": "string|null",
  "isEmailVerified": "boolean",
  "isBiometricEnabled": "boolean",
  "linkedProviders": ["string"],
  "createdAt": "string",
  "lastLoginAt": "string",
  "preferences": {
    "theme": "string",
    "language": "string",
    "followedCategories": ["string"],
    "followedSources": ["string"],
    "notificationsEnabled": "boolean",
    "emailNotificationsEnabled": "boolean",
    "pushNotificationsEnabled": "boolean"
  }
}
```

### Article Model
```json
{
  "id": "string",
  "title": "string",
  "description": "string|null",
  "url": "string",
  "urlToImage": "string|null",
  "sourceName": "string",
  "author": "string|null",
  "publishedAt": "string",
  "content": "string|null",
  "categories": ["string"],
  "isBookmarked": "boolean",
  "bookmarkedAt": "string|null",
  "isRead": "boolean",
  "readAt": "string|null",
  "createdAt": "string",
  "updatedAt": "string",
  "isSynced": "boolean"
}
```

### Sync Change Model
```json
{
  "id": "string",
  "type": "string",
  "entityId": "string",
  "data": "object",
  "timestamp": "string",
  "isApplied": "boolean"
}
```

## SDK Integration

### Flutter SDK
The Flutter SDK provides convenient wrappers for all API endpoints:

```dart
// Initialize SDK
PulseNewsSDK.initialize(apiKey: 'your_api_key');

// Authentication
final result = await PulseNews.auth.signIn(email, password);
result.fold(
  (failure) => print('Error: $failure'),
  (user) => print('Signed in: $user'),
);

// Articles
final articles = await PulseNews.articles.getTopHeadlines(
  countryCode: 'us',
  category: 'technology',
);

// Save article
await PulseNews.articles.saveArticle(article);
```

### JavaScript SDK
```javascript
// Initialize SDK
PulseNewsSDK.initialize({ apiKey: 'your_api_key' });

// Authentication
const result = await PulseNews.auth.signIn(email, password);
if (result.success) {
  console.log('Signed in:', result.user);
}

// Articles
const articles = await PulseNews.articles.getTopHeadlines({
  countryCode: 'us',
  category: 'technology'
});
```

## Webhooks

### Supported Events
- `user.created`: New user registration
- `user.deleted`: User account deletion
- `article.saved`: Article bookmarked
- `article.read`: Article marked as read
- `sync.completed`: Data synchronization completed

### Webhook Configuration
Webhooks can be configured in the developer dashboard:
1. Navigate to Settings > Webhooks
2. Add webhook URL
3. Select events to subscribe to
4. Configure secret key for security

### Webhook Payload
```json
{
  "event": "article.saved",
  "data": {
    "userId": "user_id",
    "articleId": "article_id",
    "timestamp": "2024-01-01T12:00:00Z"
  },
  "signature": "sha256_hash"
}
```

## Security Considerations

### Authentication
- Use HTTPS for all API calls
- Include API key in X-Api-Key header
- Implement token refresh logic
- Store tokens securely

### Data Validation
- Validate all input parameters
- Sanitize user-generated content
- Implement rate limiting
- Use parameterized queries

### Privacy
- Minimize data collection
- Implement data deletion
- Follow GDPR compliance
- Provide privacy controls

This API documentation provides comprehensive information for integrating with PulseNews services and building robust applications.
