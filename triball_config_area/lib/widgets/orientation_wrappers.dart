// lib/widgets/orientation_wrappers.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/screen_service.dart';
import 'orientation_lock.dart';

// ============================================================
// PORTRAIT WRAPPER
// ============================================================
class PortraitWrapper extends StatefulWidget {
  final Widget child;

  const PortraitWrapper({super.key, required this.child});

  @override
  State<PortraitWrapper> createState() => _PortraitWrapperState();
}

class _PortraitWrapperState extends State<PortraitWrapper>
    with WidgetsBindingObserver, RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyPortrait();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _applyPortrait();
    }
  }

  void _applyPortrait() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.find<ScreenService>().setPortraitNormal();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationLock(
      expectedOrientation: Orientation.portrait,
      child: widget.child,
    );
  }
}

// ============================================================
// LANDSCAPE IMMERSIVE WRAPPER — VERSION CORRIGÉE
// ============================================================
class LandscapeImmersiveWrapper extends StatefulWidget {
  final Widget child;

  const LandscapeImmersiveWrapper({super.key, required this.child});

  @override
  State<LandscapeImmersiveWrapper> createState() =>
      _LandscapeImmersiveWrapperState();
}

class _LandscapeImmersiveWrapperState
    extends State<LandscapeImmersiveWrapper>
    with WidgetsBindingObserver {

  bool _isCurrentlyMounted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyLandscape();
  }

  // ✅ NEW : Réapplique landscape quand l'app revient au premier plan
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isCurrentlyMounted) {
      _applyLandscape();
    }
  }

  // ✅ NEW : Réapplique landscape quand on revient sur cette route
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply landscape when widget becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isCurrentlyMounted) {
        _applyLandscape();
      }
    });
  }

  void _applyLandscape() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.find<ScreenService>().setLandscapeImmersive();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _isCurrentlyMounted = false;
    WidgetsBinding.instance.removeObserver(this);

    // ✅ FIX : NE PAS forcer portrait ici si on retourne vers un écran landscape
    //         On laisse le wrapper de destination gérer son orientation
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationLock(
      expectedOrientation: Orientation.landscape,
      child: widget.child,
    );
  }
}