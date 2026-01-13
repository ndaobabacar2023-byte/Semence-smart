#!/bin/bash

# Start the backend server
cd backend
npm install
npm run dev &

# Start the mobile application
cd ../mobile
flutter pub get
flutter run