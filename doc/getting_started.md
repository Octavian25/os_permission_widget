# os_permission_widget

A Flutter package to simplify permission handling and enhance user experience with a customizable UI. This widget provides a modern and intuitive interface for requesting and managing permissions in your Flutter application.

---

## Features

- Display a scrollable list of permissions.
- Customizable UI components, including titles, subtitles, and styles.
- Support for `permission_handler` package for permission requests.
- Responsive design with a loading indicator for initial permission state retrieval.
- Reusable permission model with `ValueNotifier` for reactive state updates.
- Built-in modal for requesting permissions with accept and deny options.

---

## Installation

Add this package to your project by including it in your `pubspec.yaml` file:

```yaml
dependencies:
  os_permission_widget: ^1.0.0
```

Then, run:

```bash
flutter pub get
```

---

## Usage

### Import the package
```dart
import 'package:os_permission_widget/os_permission_widget.dart';
```

### Example Implementation

Below is an example of how to use the `OsPermissionList` widget in your Flutter application.

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:os_permission_widget/os_permission_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<OsPermissionModel> permissions = [
    OsPermissionModel(
      leadingImage: "assets/sample_icon.png",
      title: "Izinkan Notifikasi",
      subtitle: "Buat ingetin kamu soal jadwal penerbangan dan check-in hotel.",
      permission: Permission.bluetoothAdvertise,
    ),
    OsPermissionModel(
      leadingImage: "assets/location.png",
      title: "Izinkan Lacak Aktivitas",
      subtitle: "Dapetin rekomendasi yang paling relevan buatmu.",
      permission: Permission.locationAlways,
      handleOnTapGrantedPopup: (context) async {
        await Permission.location.request();
        if (await Permission.locationAlways.serviceStatus.isEnabled) {
          await Permission.locationAlways.request();
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OsPermissionList(
        listPermission: permissions,
        handleFinish: () {
          // Action after all permissions are granted
          print("All permissions granted or processed.");
        },
        title: "Request Permissions",
        subtitle: "Grant the following permissions for the best app experience.",
        loadingTitle: "Loading Permissions...",
        loadingMessage: "Fetching the current permission states, please wait.",
      ),
    );
  }
}
```

---

## API Reference

### **OsPermissionList**
A widget for displaying a list of permissions and handling their states.

#### Properties:
| Property           | Type                                | Description                                                                 |
|--------------------|-------------------------------------|-----------------------------------------------------------------------------|
| `listPermission`   | `List<OsPermissionModel>`          | The list of permissions to be displayed and managed.                       |
| `handleFinish`     | `Function()`                       | Callback when all permissions are granted or processed.                    |
| `title`            | `String`                           | The title displayed in the permission list UI.                             |
| `subtitle`         | `String`                           | The subtitle explaining the need for permissions.                          |
| `loadingTitle`     | `String`                           | Title displayed during the loading state.                                  |
| `loadingMessage`   | `String`                           | Message displayed during the loading state.                                |
| `titleStyle`       | `TextStyle?`                       | Custom text style for the title.                                           |
| `subtitleStyle`    | `TextStyle?`                       | Custom text style for the subtitle.                                        |

---

### **OsPermissionModel**
The model representing each permission item.

#### Properties:
| Property                  | Type                     | Description                                                               |
|---------------------------|--------------------------|---------------------------------------------------------------------------|
| `leadingImage`            | `String`                | Path to the leading image/icon.                                            |
| `title`                   | `String`                | The title of the permission.                                               |
| `subtitle`                | `String`                | A brief explanation of why the permission is needed.                       |
| `permission`              | `Permission`            | The `permission_handler` permission object.                                |
| `handleOnTapGrantedPopup` | `Function(BuildContext)` | Custom logic when a permission is granted. This overrides the default "Allow" button behavior in the modal popup. |
| `grantedNotifier`         | `ValueNotifier<bool>`    | Reactive notifier for permission state (granted or denied).                |

---

## Customization

### Overriding the "Allow" Button Behavior
The `handleOnTapGrantedPopup` property allows you to define custom logic for handling permissions. When this property is defined, it overrides the default behavior of the "Allow" button in the modal popup.

#### Example:
```dart
OsPermissionModel(
  leadingImage: "assets/location.png",
  title: "Allow Location Access",
  subtitle: "Get the most relevant recommendations for you.",
  permission: Permission.locationAlways,
  handleOnTapGrantedPopup: (context) async {
    await Permission.location.request();
    if (await Permission.locationAlways.serviceStatus.isEnabled) {
      await Permission.locationAlways.request();
    }
  },
);
```
In this example, when the "Allow" button is tapped, the custom logic inside `handleOnTapGrantedPopup` will be executed instead of the default permission request flow.

---

## Dependencies

- [permission_handler](https://pub.dev/packages/permission_handler)

---

## Contributions

Contributions are welcome! If you encounter bugs or have feature suggestions, feel free to open an issue or create a pull request on GitHub.

---

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
