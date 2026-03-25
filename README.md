# 📡 Beacon: Off-Grid. Decenteralized. Secure.

[![App Store](https://img.shields.io/badge/Coming_Soon_to-App_Store-blue?style=for-the-badge&logo=apple)](https://beacon.datagainz.com)
[![Google Play](https://img.shields.io/badge/Coming_Soon_to-Google_Play-green?style=for-the-badge&logo=google-play)](https://beacon.datagainz.com)

**Beacon** is a mission-critical, all-around offline survival application designed to keep you connected when the grid fails. Built on the [Meshtastic](https://meshtastic.org/) protocol, Beacon brings robust group messaging, precise location tracking, and advanced hardware management to iOS, Android, and Web.

🌐 **Website**: [https://beacon.datagainz.com](https://beacon.datagainz.com)

---

## ⚡ Core Features

- **📱 Secure Off-Grid Messaging**: Send and receive encrypted text messages directly between LoRa radio devices. No cell service, no Wi-Fi, no problem.
- **🗺️ Live Map Integration**: Real-time GPS tracking for your entire team. View teammate locations on offline-cached maps for complete situational awareness.
- **🛰️ Node Management**: Seamlessly scan for, pair with, and manage your Meshtastic nodes via Bluetooth Low Energy (BLE).
- **⚙️ Deep Configuration**: Adjust every hardware setting—from LoRa frequency and power levels to MQTT bridges and custom module configs.
- **🛡️ Admin Protocol 2.0+**: Full support for the latest Meshtastic AdminProtocol, ensuring secure, authenticated sessions for hardware changes.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Multi-platform: iOS, Android, Web)
- **Language**: [Dart](https://dart.dev/)
- **Communication**: [Protobuf](https://protobuf.dev/) & [Bluetooth Low Energy](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy)
- **Mapping**: [flutter_map](https://pub.dev/packages/flutter_map) with advanced ObjectBox tile caching.

---

## 🚀 Getting Started

1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/joshuaahughes/beacon.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 📅 Roadmap

We are currently in active beta. Beacon will be hitting the **App Store** and **Google Play Store** soon! 

Stay tuned for:
- [ ] Direct ATAK (TAK) integration.
- [ ] Hybrid Online/Offline map transition.
- [ ] Enterprise Node Fleet management.

---

© 2026 Beacon Team. [datagainz.com](https://datagainz.com)
