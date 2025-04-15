# Acumen

<p align="center">
  <img src="assets/images/logo/logo.png" alt="Acumen Logo" width="200"/>
</p>

## About Acumen

Acumen is a comprehensive career development and mentorship platform designed to help individuals advance their professional journeys. The app connects users with experienced mentors, provides personalized career insights, and offers learning resources to build essential skills.

## Key Features

- **Personalized Dashboard**: Custom-tailored content based on user's career interests and goals
- **Mentor Connections**: Connect with industry professionals for guidance and advice
- **Career Assessments**: Take quizzes to identify strengths and suitable career paths
- **Skill Development**: Access learning resources to build professional skills
- **Messaging System**: Communicate directly with mentors through the in-app chat
- **Profile Management**: Create and manage detailed user profiles showcasing skills and experience
- **Authentication**: Secure login, signup, and password management
- **Settings**: Customize app preferences, privacy options, and security settings

## Technical Implementation

- **Frontend**: Built with Flutter for cross-platform compatibility (iOS and Android)
- **Architecture**: Follows a clean, modular architecture for maintainability
- **State Management**: Implements efficient state management for responsive UI
- **Theme**: Custom theme with consistent design elements across the app
- **Localization**: Support for multiple languages (planned for future releases)

## Project Structure

```
lib/
├── main.dart         # Application entry point
├── routes/           # App navigation and routing
├── screens/          # UI screens organized by feature
├── widgets/          # Reusable UI components
├── theme/            # App theming and styling
├── models/           # Data models
├── services/         # Business logic and backend communication
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.2 or higher)
- Dart SDK
- Android Studio / Xcode for native development

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-organization/acumen.git
   ```

2. Navigate to the project directory:
   ```
   cd acumen
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

### Building for Production

- Android APK:
  ```
  flutter build apk
  ```

- iOS:
  ```
  flutter build ios
  ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For inquiries or support, please contact [your-email@example.com](mailto:your-email@example.com).
