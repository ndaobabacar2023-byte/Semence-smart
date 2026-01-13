# AgriAdvisor Mobile Application

## Overview
AgriAdvisor is a mobile application designed to provide agricultural advice and resources to users. This README outlines the setup instructions and provides an overview of the application's structure.

## Getting Started

### Prerequisites
- Flutter SDK installed on your machine.
- An IDE such as Android Studio or Visual Studio Code.
- An emulator or physical device for testing.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd AgriAdvisor/mobile
   ```

2. **Install dependencies:**
   Run the following command to install the required packages:
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   You can run the application on an emulator or a physical device using:
   ```bash
   flutter run
   ```

### Directory Structure
- `lib/`: Contains the main application code.
  - `main.dart`: Entry point of the application.
  - `app.dart`: Main application widget.
  - `src/`: Contains the source code organized into models, services, screens, widgets, and utils.
- `test/`: Contains widget tests for the application.

## Features
- User authentication (login and registration).
- Home screen displaying agricultural advice.
- Advisory screen for analyzing conditions.
- User profile management.

## API Integration
The mobile application communicates with the backend API for user authentication and advisory data. Ensure the backend server is running and accessible.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.