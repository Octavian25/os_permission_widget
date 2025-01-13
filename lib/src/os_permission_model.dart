import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class OsPermissionModel {
  String leadingImage;
  String title;
  TextStyle? titleStyle;
  String subtitle;
  TextStyle? subtitleStyle;
  final ValueNotifier<bool> grantedNotifier;
  Permission permission;
  Function()? onTap;
  Function(BuildContext context)? handleOnTapGrantedPopup;

  OsPermissionModel(
      {required this.leadingImage,
      required this.title,
      required this.subtitle,
      required this.permission,
      this.handleOnTapGrantedPopup,
      this.titleStyle,
      this.subtitleStyle,
      bool granted = false,
      this.onTap})
      : grantedNotifier = ValueNotifier(granted);
}
