// triball_config_area/lib/features/setup/widgets/setup_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/controllers/config_broadcaster_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_button.dart';
import '../game_setup_controller.dart';

class SetupNavigationBar extends GetView<GameSetupController> {
  const SetupNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final broadcaster = Get.find<ConfigBroadcasterController>();

    return Obx(() {
      final isLast = controller.isLastPage;
      final isFirst = controller.isFirstPage &&
          !controller.matchTypePreselected.value;
      final isSending = controller.isSending.value;
      final hasGameArea = broadcaster.hasGameAreaConnected;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Warning si pas de Game Area connectée (dernière page)
            if (isLast && !hasGameArea)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: ThemeColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ThemeColors.warning.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tv_off,
                        color: ThemeColors.warning, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'no_game_area_warning'.tr,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10.sp,
                          color: ThemeColors.warning,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Navigation buttons
            Row(
              children: [
                // Bouton retour / précédent
                if (!isFirst)
                  Expanded(
                    flex: 2,
                    child: ThemedButton(
                      label: 'back'.tr,
                      icon: Icons.arrow_back,
                      variant: ButtonVariant.ghost,
                      height: 50.h,
                      fontSize: 13.sp,
                      onPressed: isSending ? null : controller.previousPage,
                    ),
                  ),
                if (!isFirst) SizedBox(width: 10.w),

                // Bouton next / ENVOYER
                Expanded(
                  flex: 3,
                  child: isLast
                      ? ThemedButton(
                    // ✅ BOUTON ENVOYER (dernière page)
                    label: isSending
                        ? 'sending'.tr
                        : '${'send_to_screen'.tr}  →  ${controller.targetScore} pts',
                    icon: isSending
                        ? Icons.hourglass_top
                        : Icons.send,
                    variant: ButtonVariant.primary,
                    height: 50.h,
                    fontSize: 12.sp,
                    onPressed: isSending
                        ? null
                        : (controller.canSendToGameArea
                        ? controller.sendToGameArea
                        : controller.canStart
                        ? controller.sendToGameArea
                        : null),
                  )
                      : ThemedButton(
                    // BOUTON NEXT (pages intermédiaires)
                    label: 'next'.tr,
                    icon: Icons.arrow_forward,
                    variant: ButtonVariant.primary,
                    height: 50.h,
                    fontSize: 13.sp,
                    onPressed: controller.canGoNext
                        ? controller.nextPage
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}