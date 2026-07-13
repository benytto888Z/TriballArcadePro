// triball_config_area/lib/features/settings/widgets/data_management_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/services/settings_export_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/themed_button.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class DataManagementCard extends StatelessWidget {
  const DataManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage,
                  color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('data_management'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== EXPORT =====
          ThemedButton(
            label: 'export_settings'.tr,
            icon: Icons.file_download,
            variant: ButtonVariant.secondary,
            fullWidth: true,
            height: 40.h,
            fontSize: 11.h,
            onPressed: () async {
              try {
                final exportService = Get.find<SettingsExportService>();
                await exportService.copyToClipboard();
                Helpers.showSnackbar(
                  'success'.tr,
                  'settings_exported_to_clipboard'.tr,
                  color: ThemeColors.success,
                  icon: Icons.check_circle,
                );
              } catch (e) {
                Helpers.showSnackbar(
                  'error'.tr,
                  e.toString(),
                  color: ThemeColors.error,
                );
              }
            },
          ),
          SizedBox(height: 8.h),

          // ===== IMPORT =====
          ThemedButton(
            label: 'import_settings'.tr,
            icon: Icons.file_upload,
            variant: ButtonVariant.accent,
            fullWidth: true,
            height: 40.h,
            fontSize: 11.h,
            onPressed: () => _showImportDialog(),
          ),
          SizedBox(height: 8.h),

          Divider(
              color: ThemeColors.primary.withOpacity(0.2), height: 1),
          SizedBox(height: 10.h),

          // ===== RESET ALL =====
          ThemedButton(
            label: 'reset_all_data'.tr,
            icon: Icons.delete_forever,
            variant: ButtonVariant.secondary,
            fullWidth: true,
            height: 40.h,
            fontSize: 11.h,
            onPressed: () => _confirmReset(),
          ),
          SizedBox(height: 10.h),

          // ===== INFO =====
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: ThemeColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ThemeColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: ThemeColors.warning, size: 14.h),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'data_management_info'.tr,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9.h,
                      color: ThemeColors.warning,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final ctrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: ThemeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: ThemeColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.file_upload,
                      color: ThemeColors.primary, size: 22.h),
                  SizedBox(width: 8.w),
                  ThemedText.title(
                      'import_settings'.tr, fontSize: 14.h),
                ],
              ),
              SizedBox(height: 12.h),
              ThemedText.caption(
                'import_paste_json'.tr,
                fontSize: 11.h,
                color: ThemeColors.textSecondary,
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 200.h,
                child: TextField(
                  controller: ctrl,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10.h,
                    color: ThemeColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '{ "app_version": "1.0.0", ... }',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                          color: ThemeColors.textSecondary),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final exportService =
                        Get.find<SettingsExportService>();
                        final success = await exportService
                            .importFromJson(ctrl.text);
                        Get.back();
                        if (success) {
                          Helpers.showSnackbar(
                            'success'.tr,
                            'settings_imported'.tr,
                            color: ThemeColors.success,
                            icon: Icons.check_circle,
                          );
                          Future.delayed(
                              const Duration(seconds: 1), () {
                            _showRestartDialog();
                          });
                        } else {
                          Helpers.showSnackbar(
                            'error'.tr,
                            'import_failed'.tr,
                            color: ThemeColors.error,
                          );
                        }
                      } catch (e) {
                        Get.back();
                        Helpers.showSnackbar(
                          'error'.tr,
                          e.toString(),
                          color: ThemeColors.error,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                    ),
                    child: Text('import'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestartDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Text(
          'restart_required'.tr,
          style: TextStyle(color: ThemeColors.primary),
        ),
        content: Text('restart_required_desc'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.warning, color: ThemeColors.error),
            SizedBox(width: 8.w),
            Text(
              'reset_all_data'.tr,
              style: TextStyle(color: ThemeColors.error),
            ),
          ],
        ),
        content: Text(
          'reset_all_data_confirm'.tr,
          style: TextStyle(fontSize: 12.h),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              try {
                final exportService =
                Get.find<SettingsExportService>();
                await exportService.resetAllData();
                Get.back();
                Helpers.showSnackbar(
                  'success'.tr,
                  'all_data_reset'.tr,
                  color: ThemeColors.success,
                );
                Future.delayed(const Duration(seconds: 2), () {
                  Get.offAllNamed(AppRoutes.splash);
                });
              } catch (e) {
                Get.back();
                Helpers.showSnackbar(
                  'error'.tr,
                  e.toString(),
                  color: ThemeColors.error,
                );
              }
            },
            child: Text(
              'reset_confirm'.tr,
              style: TextStyle(
                color: ThemeColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}