# AgriAdvisor Backend Documentation

## Overview
AgriAdvisor is a full-stack application designed to provide agricultural advice and resources to users. The backend is built using Node.js and Express, with MongoDB as the database.

## Setup Instructions

### Prerequisites
- Node.js (version 14 or higher)
- MongoDB (local or cloud instance)
- TypeScript (optional, if you want to compile TypeScript files)

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/AgriAdvisor.git
   cd AgriAdvisor/backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Configure environment variables:
   - Copy `.env.example` to `.env` and fill in the required values:
     ```
     PORT=5000
     MONGO_URI=mongodb://localhost:27017/agriadvisor
     JWT_SECRET=your_jwt_secret
     ```

### Running the Application
To start the development server, run:
```
npm run dev
```

### API Endpoints
- **Authentication**
  - `POST /api/auth/register` - Register a new user
  - `POST /api/auth/login` - Login an existing user

- **Advisory**
  - `GET /api/advisory` - Get all advisory resources
  - `POST /api/advisory` - Create a new advisory resource

### Testing
To run tests, use:
```
npm test
```

## License
This project is licensed under the MIT License. See the LICENSE file for more details.