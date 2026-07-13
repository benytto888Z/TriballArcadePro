// triball_config_area/lib/widgets/avatar_capture_dialog.dart

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/services/avatar_capture_service.dart';
import '../core/theme/theme_colors.dart';
import '../widgets/themed_button.dart';

class AvatarCaptureDialog extends StatefulWidget {
  final String playerName;
  final int playerIndex;

  const AvatarCaptureDialog({
    super.key,
    required this.playerName,
    required this.playerIndex,
  });

  @override
  State<AvatarCaptureDialog> createState() => _AvatarCaptureDialogState();
}

class _AvatarCaptureDialogState extends State<AvatarCaptureDialog> {
  late final AvatarCaptureService _avatarService;
  CameraController? _cameraCtrl;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _hasError = false;
  String _errorMsg = '';
  Uint8List? _capturedBytes;

  @override
  void initState() {
    super.initState();
    try {
      _avatarService = Get.find<AvatarCaptureService>();
      _initCamera();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMsg = 'camera_not_available'.tr;
      });
    }
  }

  Future<void> _initCamera() async {
    _cameraCtrl = await _avatarService.initializeCamera();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_cameraCtrl == null) {
          _hasError = true;
          _errorMsg = 'camera_init_failed'.tr;
        }
      });
    }
  }

  Future<void> _capture() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    final base64 = await _avatarService.captureAvatar(widget.playerIndex);

    if (mounted) {
      if (base64 != null) {
        setState(() {
          _capturedBytes = _avatarService.getPreviewBytes(widget.playerIndex);
          _isCapturing = false;
        });
      } else {
        setState(() {
          _isCapturing = false;
          _hasError = true;
          _errorMsg = 'capture_failed'.tr;
        });
      }
    }
  }

  void _confirm() {
    _avatarService.disposeCamera();
    Get.back();
  }

  void _retake() {
    _avatarService.removeAvatar(widget.playerIndex);
    setState(() {
      _capturedBytes = null;
      _hasError = false;
      _errorMsg = '';
    });
  }

  void _skip() {
    _avatarService.disposeCamera();
    Get.back();
  }

  void _removeExisting() {
    _avatarService.removeAvatar(widget.playerIndex);
    _avatarService.disposeCamera();
    Get.back();
  }

  @override
  void dispose() {
    // Ne pas disposer la caméra ici si confirm/skip l'a déjà fait
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ThemeColors.primary.withOpacity(0.5)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============= HEADER =============
              Row(
                children: [
                  Icon(Icons.camera_alt,
                      color: ThemeColors.primary, size: 22.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'take_photo_for'.tr,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10.sp,
                            color: ThemeColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          widget.playerName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: ThemeColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _skip,
                    icon: Icon(Icons.close,
                        color: ThemeColors.textSecondary, size: 22.sp),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // ============= PREVIEW AREA =============
              Container(
                width: 220.w,
                height: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _capturedBytes != null
                        ? ThemeColors.success
                        : ThemeColors.primary,
                    width: 3,
                  ),
                  boxShadow: ThemeColors.useGlow
                      ? [
                    BoxShadow(
                      color: (_capturedBytes != null
                          ? ThemeColors.success
                          : ThemeColors.primary)
                          .withOpacity(0.4),
                      blurRadius: 16,
                    ),
                  ]
                      : null,
                ),
                child: ClipOval(child: _buildPreviewContent()),
              ),
              SizedBox(height: 20.h),

              // ============= BUTTONS =============
              if (_hasError) ...[
                // Erreur state
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: ThemeColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeColors.error.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: ThemeColors.error, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMsg,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10.sp,
                            color: ThemeColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                ThemedButton(
                  label: 'close'.tr,
                  icon: Icons.close,
                  variant: ButtonVariant.ghost,
                  width: 160.w,
                  height: 42.h,
                  fontSize: 12.sp,
                  onPressed: _skip,
                ),
              ] else if (_capturedBytes == null) ...[
                // Pas encore de photo
                ThemedButton(
                  label: _isCapturing
                      ? 'capturing'.tr
                      : 'take_photo'.tr,
                  icon: _isCapturing
                      ? Icons.hourglass_top
                      : Icons.camera,
                  variant: ButtonVariant.primary,
                  width: 200.w,
                  height: 48.h,
                  fontSize: 14.sp,
                  onPressed: (_isLoading || _isCapturing) ? null : _capture,
                ),
                SizedBox(height: 8.h),
                ThemedButton(
                  label: 'skip'.tr,
                  icon: Icons.skip_next,
                  variant: ButtonVariant.ghost,
                  width: 160.w,
                  height: 36.h,
                  fontSize: 10.sp,
                  onPressed: _skip,
                ),
              ] else ...[
                // Photo capturée → Confirmer ou Reprendre
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemedButton(
                      label: 'retake'.tr,
                      icon: Icons.refresh,
                      variant: ButtonVariant.ghost,
                      width: 130.w,
                      height: 44.h,
                      fontSize: 12.sp,
                      onPressed: _retake,
                    ),
                    SizedBox(width: 10.w),
                    ThemedButton(
                      label: 'confirm'.tr,
                      icon: Icons.check,
                      variant: ButtonVariant.primary,
                      width: 130.w,
                      height: 44.h,
                      fontSize: 12.sp,
                      onPressed: _confirm,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Option supprimer la photo existante
                if (_avatarService.hasAvatar(widget.playerIndex))
                  TextButton.icon(
                    onPressed: _removeExisting,
                    icon: Icon(Icons.delete_outline,
                        color: ThemeColors.error, size: 14.sp),
                    label: Text(
                      'remove_photo'.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10.sp,
                        color: ThemeColors.error,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    // Loading
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: ThemeColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 12.h),
              Text(
                'loading'.tr,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10.sp,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Photo capturée → preview
    if (_capturedBytes != null) {
      return Image.memory(
        _capturedBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Icon(Icons.broken_image,
                  color: ThemeColors.error, size: 40.sp),
            ),
          );
        },
      );
    }

    // Camera preview live
    if (_cameraCtrl != null && _cameraCtrl!.value.isInitialized) {
      return SizedBox(
        width: 220.w,
        height: 220.w,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraCtrl!.value.previewSize?.height ?? 220,
            height: _cameraCtrl!.value.previewSize?.width ?? 220,
            child: CameraPreview(_cameraCtrl!),
          ),
        ),
      );
    }

    // Erreur ou pas de caméra
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt,
                color: ThemeColors.textSecondary.withOpacity(0.5),
                size: 50.sp),
            SizedBox(height: 8.h),
            Text(
              'camera_not_available'.tr,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10.sp,
                color: ThemeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}