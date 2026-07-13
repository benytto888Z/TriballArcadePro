// triball_game_area/lib/routes/app_pages.dart

import 'package:get/get.dart';
import '../features/tournament/tournament_bracket_screen.dart';
import '../features/tournament/tournament_controller.dart';
import 'app_routes.dart';
import '../features/splash/splash_screen.dart';
import '../features/splash/splash_controller.dart';
import '../features/waiting/waiting_screen.dart';
import '../features/waiting/waiting_controller.dart';
import '../features/game/game_screen.dart';
import '../features/game/game_controller.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/leaderboard/leaderboard_controller.dart';

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
      name: AppRoutes.waiting,
      page: () => const WaitingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WaitingController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => GameController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.leaderboard,
      page: () => const LeaderboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LeaderboardController());
      }),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.tournamentBracket,
      page: () => const TournamentBracketScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TournamentController(), fenix: true);
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}