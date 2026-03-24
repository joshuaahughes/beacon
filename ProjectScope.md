Beacon Implementation Plan
Goal Description
To build a 1:1 clone of the Meshtastic Android application using Flutter (supporting iOS, Android, and Web). Ensure full parity with existing Meshtastic features while adding a core feature: Offline Maps as the primary map display. The project will strictly adhere to Test-Driven Development (TDD) as defined in 

gemini.md
.

User Review Required
IMPORTANT

Please review the chosen technology stack below. We plan to use flutter_map with MBTiles for offline map support and flutter_blue_plus for Bluetooth interactions. Let me know if you have different library preferences! Also, please verify you are ready for me to initialize the Flutter project in the current directory.

Architecture & Technology Stack
UI Framework: Flutter (Material 3 design mirroring the native app)
State Management: Riverpod (unidirectional data flow, similar to the native app's ViewModel/Coroutines/Flow approach)
Data Layer: Isar Database or sqflite (local caching, node storage, message persistence)
Bluetooth/BLE: flutter_blue_plus for seamless cross-platform Nordic BLE integration.
Device Communication: Dart implementation of Protocol Buffers (protobuf) to serialize/deserialize data for the Meshtastic hardware.
Mapping: flutter_map combined with flutter_map_mbtiles (or flutter_map_tile_caching) to allow offline map tile downloads and rendering.
Proposed Changes
Core Project Structure
[NEW] lib/core/
Contains generic application logic: routing (go_router), error handling, thematic configurations, and Dependency Injection setups.

[NEW] lib/data/
Repositories interacting with Protocol Buffers, local database, and SharedPreferences.

[NEW] lib/features/
The main domains mirroring the Android app:

messaging: Conversations and sending/receiving texts.
nodes: Displaying mesh topography, node lists, and metadata.
map: The custom Offline Map implementation visualizing GPS data.
settings: Device and application configurations.
The Offline Maps Feature
The Maps tab will allow users to:

Check their bounding box and download maps for local caching.
Store map tiles using path_provider.
Render the cache via flutter_map with no network requests being made.
Verification Plan
Automated Tests
Unit testing for all Repositories and Riverpod Providers before UI implementation.
Widget testing for all UI fragments.
Mocked BLE provider test suite to ensure robust handling of device disconnects.
Manual Verification
Deploy to Android/iOS and verify map tiles render after explicitly turning off Wi-Fi/Cellular.
Connect to an actual Meshtastic node and verify channel message synchronizations.