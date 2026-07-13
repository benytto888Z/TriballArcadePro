// triball_game_area/lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';

import 'core/controllers/config_listener_controller.dart';
import 'core/controllers/websocket_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'core/services/ websocket_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/avatar_storage_service.dart';
import 'core/services/game_settings_service.dart';
import 'core/services/screen_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme_controller.dart';
import 'core/utils/platform_helper.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init audio pour Windows
  AudioService.registerWith();

  await GetStorage.init();

  // ============================================
  // ✅ WINDOW MANAGER — Fullscreen immersif
  // ============================================
  if (PlatformHelper.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      // Taille par défaut (sera fullscreen après)
      size: Size(1920, 1080),
      center: true,
      // ✅ Pas de title bar
      titleBarStyle: TitleBarStyle.hidden,
      // ✅ Pas de frame (bordures)
      skipTaskbar: false,
      backgroundColor: Colors.transparent,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      // ✅ Fullscreen immersif complet
      await windowManager.setFullScreen(true);

      // ✅ Empêcher le redimensionnement
      await windowManager.setResizable(false);

      // ✅ Toujours au premier plan (optionnel pour TV)
     // await windowManager.setAlwaysOnTop(true);

      // ✅ Empêcher la fermeture accidentelle
      await windowManager.setPreventClose(true);

      // ✅ Empêcher de minimiser
      await windowManager.setMinimizable(false);

      // ✅ Afficher la fenêtre
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // ============================================
  // GLOBAL SERVICES
  // ============================================
  Get.put(ScreenService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(WebSocketService(), permanent: true);
  Get.put(WebSocketController(), permanent: true);
  Get.put(AudioService(), permanent: true);
  Get.put(TtsService(), permanent: true);
  Get.put(AppThemeController(), permanent: true);
  Get.put(LocaleController(), permanent: true);
  Get.put(GameSettingsService(), permanent: true);
  Get.put(ConfigListenerController(), permanent: true);
  Get.put(AvatarStorageService(), permanent: true);   // ✅ NEW

  if (kDebugMode) {
    print('════════════════════════════════════════');
    print('  📺 TRIBALL PRO GAME AREA v1.0.0');
    print('  Platform: ${PlatformHelper.name}');
    print('  Role: game_area');
    print('  Mode: FULLSCREEN IMMERSIVE');
    print('════════════════════════════════════════');
  }

  runApp(const TriballGameApp());
}

// ============================================
// ✅ WINDOW LISTENER — Empêche la fermeture accidentelle
// ============================================
class _GameWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    // ✅ Empêche la fermeture par Alt+F4 ou clic sur X (si visible)
    // Pour quitter : il faudra un code admin ou un bouton dans Settings
    final shouldClose = await _showExitConfirmation();
    /*if (shouldClose) {
      await windowManager.destroy();
    }*/
  }

  Future<bool> _showExitConfirmation() async {
    // En production, on empêche complètement la fermeture
    // Pour debug, on autorise
    return kDebugMode;
  }
}

class TriballGameApp extends StatefulWidget {
  const TriballGameApp({super.key});

  @override
  State<TriballGameApp> createState() => _TriballGameAppState();
}

class _TriballGameAppState extends State<TriballGameApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (PlatformHelper.isWindows) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (PlatformHelper.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  // ✅ Empêcher la fermeture accidentelle
  @override
  void onWindowClose() async {
    if (kDebugMode) {
      // En debug, autorise la fermeture
      await windowManager.destroy();
    } else {
      // En production, empêche la fermeture
      // (il faudra un code admin pour quitter)
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<AppThemeController>();
    final localeController = Get.find<LocaleController>();

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
          title: 'Triball Pro Game Area',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentThemeData,
          darkTheme: themeController.currentThemeData,
          themeMode: ThemeMode.dark,
          translations: AppTranslations(),
          locale: localeController.currentLocale.value,
          fallbackLocale: const Locale('fr', 'FR'),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          builder: (context, widget) {
            if (widget == null) return const SizedBox.shrink();
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: widget,
            );
          },
        ));
      },
    );
  }
}