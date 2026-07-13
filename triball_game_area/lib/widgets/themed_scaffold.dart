// lib/widgets/themed_scaffold.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';
import 'animated_background.dart';


class ThemedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool withAnimatedBackground;
  final bool extendBodyBehindAppBar;

  const ThemedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.withAnimatedBackground = true,
    this.extendBodyBehindAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ignore: unused_local_variable
      final mode = Get.find<AppThemeController>().currentTheme.value;

      return Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        body: Container(
          decoration: BoxDecoration(
            gradient: ThemeColors.backgroundGradient,
          ),
          child: Stack(
            children: [
              if (withAnimatedBackground) const AnimatedBackground(),
              SafeArea(child: Center(child: body)),
            ],
          ),
        ),
      );
    });
  }
}