# Meshager - Meshtastic Device Manager

A Flutter application for managing Meshtastic devices, allowing you to connect to devices via Bluetooth, send text messages, and manage device settings.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (latest stable version)
   - Download from [Flutter's official website](https://flutter.dev/docs/get-started/install)
   - Follow the installation instructions for your operating system
   - Verify installation by running `flutter doctor` in your terminal


## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd meshager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome
   ```
   This will:
   - Start a local development server
   - Open the app in your default browser
   - Enable hot reload for development

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
├── providers/            # State management
├── protos/              # Protocol buffer definitions
├── screens/             # UI screens
└── services/            # Business logic services
```

## Key Features

- Bluetooth device scanning and connection
- Text message sending
- Device settings management
- Real-time device status monitoring

## Development Notes

- The app uses Provider for state management
- Bluetooth functionality is implemented using flutter_blue_plus
- Protocol buffer definitions are in the protos directory

## Troubleshooting

If you encounter any issues:

1. **Flutter Doctor**
   ```bash
   flutter doctor
   ```
   This will check your setup and identify any issues.

2. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```


