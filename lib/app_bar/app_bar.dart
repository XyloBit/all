import 'package:flutter/material.dart';

import '../constent.dart';
import 'app_color.dart';

class AppBarWidget {
  static AppBar appbar() {
    return AppBar(
      backgroundColor: ThemeColors.blue,
      title: const Text(AppName.appName),
      toolbarHeight: 35,
    );
  }
}
