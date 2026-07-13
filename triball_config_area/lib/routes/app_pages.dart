// triball_config_area/lib/routes/app_pages.dart

import 'package:get/get.dart';
import '../features/leaderboard_remote/leaderboard_remote_screen.dart';
import 'app_routes.dart';
import '../features/splash/splash_screen.dart';
import '../features/splash/splash_controller.dart';
import '../features/home/home_screen.dart';
import '../features/home/home_controller.dart';
import '../features/setup/game_setup_screen.dart';
import '../features/setup/game_setup_controller.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/how_to_play/how_to_play_screen.dart';
import '../features/how_to_play/how_to_play_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.gameSetup,
      page: () => const GameSetupScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => GameSetupController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.howToPlay,
      page: () => const HowToPlayScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HowToPlayController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.leaderboardRemote,
      page: () => const LeaderboardRemoteScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}