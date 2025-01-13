import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:os_permission_widget/os_permission_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<OsPermissionModel> permissions = [
    OsPermissionModel(
      leadingImage: "assets/sample_icon.png",
      title: "Allow Notifications",
      subtitle: "To remind you about flight schedules and hotel check-ins.",
      permission: Permission.bluetoothAdvertise,
    ),
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
