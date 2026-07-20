// triball_config_area/lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/controllers/config_broadcaster_controller.dart';
import 'core/controllers/websocket_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'core/services/ websocket_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/avatar_capture_service.dart';
import 'core/services/game_settings_service.dart';
import 'core/services/game_session_guard_service.dart';
import 'core/services/platform_config_service.dart';
import 'core/services/screen_service.dart';
import 'core/services/settings_export_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme_controller.dart';
import 'core/utils/platform_helper.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'widgets/config_area_lock_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init audio pour Windows/Linux (au cas où)
  AudioService.registerWith();

  // ✅ Init storage
  await GetStorage.init();

  // ✅ FORCE PORTRAIT (mobile/tablette uniquement)
  if (PlatformHelper.isMobile) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // System UI transparent (Android)
  if (PlatformHelper.isAndroid) {
     SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
  Get.put(PlatformConfigService(), permanent: true);    // ✅ GARDER
  Get.put(ConfigBroadcasterController(), permanent: true);
  Get.put(GameSessionGuardService(), permanent: true);
  Get.put(SettingsExportService(), permanent: true);
  Get.put(AvatarCaptureService(), permanent: true);

  await Get.find<ScreenService>().setPortraitNormal();

  if (kDebugMode) {
    print('════════════════════════════════════════');
    print('  📱 TRIBALL PRO CONFIG AREA v1.0.0');
    print('  Platform: ${PlatformHelper.name}');
    print('  Role: config_area');
    print('════════════════════════════════════════');
  }

  runApp(const TriballConfigApp());
}

class TriballConfigApp extends StatelessWidget {
  const TriballConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<AppThemeController>();
    final localeController = Get.find<LocaleController>();

    return ScreenUtilInit(
      // ✅ Portrait design size
      designSize: const Size(384, 829),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
          title: 'Triball Pro Config',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentThemeData,
          darkTheme: themeController.currentThemeData,
          themeMode: ThemeMode.dark,
          translations: AppTranslations(),
          locale: localeController.currentLocale.value,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          builder: (context, widget) {
            if (widget == null) return const SizedBox.shrink();
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: ConfigAreaLockOverlay(child: widget),
            );
          },
        ));
      },
    );
  }
}