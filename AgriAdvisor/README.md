# AgriAdvisor Project

AgriAdvisor is a full-stack application designed to provide agricultural advice and resources to users. This project consists of a Flutter mobile application, a Node.js/Express backend, and a MongoDB database.

## Table of Contents

- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Backend Setup](#backend-setup)
  - [Mobile Setup](#mobile-setup)
- [API Endpoints](#api-endpoints)
- [Examples of API Calls](#examples-of-api-calls)

## Project Structure

```
AgriAdvisor
├── mobile
│   ├── lib
│   ├── android
│   ├── ios
│   └── ...
├── backend
│   ├── src
│   ├── tests
│   └── ...
├── infra
│   ├── docker
│   └── mongo
└── scripts
```

## Setup Instructions

### Backend Setup

1. Navigate to the `backend` directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file based on the `.env.example` file and configure the necessary environment variables:
   ```
   PORT=5000
   MONGO_URI=mongodb://localhost:27017/agriadvisor
   JWT_SECRET=your_jwt_secret
   ```

4. Start the backend server:
   ```
   npm run dev
   ```

### Mobile Setup

1. Navigate to the `mobile` directory:
   ```
   cd mobile
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the application:
   ```
   flutter run
   ```

## API Endpoints

- **Authentication**
  - `POST /api/auth/register` - Register a new user
  - `POST /api/auth/login` - Login an existing user

- **Advisory**
  - `GET /api/advisory` - Get advisory information
  - `POST /api/advisory` - Create a new advisory entry

## Examples of API Calls

### Register a User

```bash
curl -X POST http://localhost:5000/api/auth/register \
-H "Content-Type: application/json" \
-d '{"username": "testuser", "password": "password123"}'
```

### Login a User

```bash
curl -X POST http://localhost:5000/api/auth/login \
-H "Content-Type: application/json" \
-d '{"username": "testuser", "password": "password123"}'
```

### Get Advisory Information

```bash
curl -X GET http://localhost:5000/api/advisory
```

## Conclusion

AgriAdvisor aims to empower users with the necessary tools and information to make informed agricultural decisions. Follow the setup instructions to get started with both the backend and mobile applications.