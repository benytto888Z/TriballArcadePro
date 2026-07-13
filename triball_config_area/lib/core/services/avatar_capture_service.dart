// triball_config_area/lib/core/services/avatar_capture_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../constants/game_constants.dart';
import '../controllers/platform_event_bus.dart';

class AvatarCaptureService extends GetxService {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  final RxBool isInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isServerRunning = false.obs;
  final RxString lastError = ''.obs;
  final RxString serverIp = ''.obs;
  final RxInt serverPort = 8080.obs;

  // ============================================
  // STOCKAGE AVATARS EN MÉMOIRE
  // ============================================
  /// Map playerIndex → JPEG bytes
  final Map<int, Uint8List> _avatarBytes = {};

  /// Map playerIndex → Base64 (pour preview local)
  final RxMap<int, String> avatarPreviews = <int, String>{}.obs;

  // Serveur HTTP
  HttpServer? _httpServer;

  StreamSubscription<void>? _clearSub;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _initCameras();
    _startHttpServer();
    _listenToClear();       // ✅ NEW
  }

  @override
  void onClose() {
    _cameraController?.dispose();
    _stopHttpServer();
    _clearSub?.cancel();    // ✅ NEW
    super.onClose();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (kDebugMode) {
        print('📸 Cameras found: ${_cameras.length}');
      }
    } catch (e) {
      if (kDebugMode) print('📸 Camera init error: $e');
      lastError.value = e.toString();
    }
  }

  // ============================================
  // CAMERA
  // ============================================
  CameraDescription? get frontCamera {
    try {
      return _cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
      );
    } catch (_) {
      return _cameras.isNotEmpty ? _cameras.first : null;
    }
  }

  bool get hasFrontCamera => frontCamera != null;

  Future<CameraController?> initializeCamera() async {
    final camera = frontCamera;
    if (camera == null) {
      lastError.value = 'No front camera available';
      return null;
    }

    try {
      _cameraController?.dispose();
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      isInitialized.value = true;
      return _cameraController;
    } catch (e) {
      lastError.value = e.toString();
      return null;
    }
  }

  CameraController? get controller => _cameraController;

  Future<void> disposeCamera() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
      isInitialized.value = false;
    } catch (_) {}
  }

  // ============================================
  // ✅ CAPTURE PHOTO
  // ============================================
  Future<String?> captureAvatar(int playerIndex) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    if (isCapturing.value) return null;
    isCapturing.value = true;

    try {
      final xFile = await _cameraController!.takePicture();
      final rawBytes = await xFile.readAsBytes();

      // Décoder
      img.Image? image = img.decodeImage(rawBytes);
      if (image == null) return null;

      // Corriger orientation
      image = img.bakeOrientation(image);

      // Miroir horizontal (caméra frontale)
      image = img.flipHorizontal(image);

      // Crop carré centré
      final cropSize = image.width < image.height ? image.width : image.height;
      final offsetX = (image.width - cropSize) ~/ 2;
      final offsetY = (image.height - cropSize) ~/ 2;
      image = img.copyCrop(image, x: offsetX, y: offsetY,
          width: cropSize, height: cropSize);

      // Redimensionner
      image = img.copyResize(image,
          width: GameConstants.avatarMaxSize,
          height: GameConstants.avatarMaxSize);

      // Encoder JPEG
      final jpegBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: GameConstants.avatarJpegQuality),
      );

      // Stocker en mémoire
      _avatarBytes[playerIndex] = jpegBytes;

      // Base64 pour preview local
      final base64 = base64Encode(jpegBytes);
      avatarPreviews[playerIndex] = base64;

      // Nettoyer fichier temp
      try {
        await File(xFile.path).delete();
      } catch (_) {}

      if (kDebugMode) {
        print('📸 Avatar captured for player $playerIndex '
            '(${jpegBytes.length} bytes)');
      }

      return base64;
    } catch (e) {
      if (kDebugMode) print('📸 Capture error: $e');
      lastError.value = e.toString();
      return null;
    } finally {
      isCapturing.value = false;
    }
  }

  // ============================================
  // ✅ SERVEUR HTTP — Sert les photos
  // ============================================
  Future<void> _startHttpServer() async {
    try {
      final router = Router();

      // Route : GET /avatar/{index}
      router.get('/avatar/<index>', (shelf.Request request, String index) {
        final idx = int.tryParse(index);
        if (idx == null || !_avatarBytes.containsKey(idx)) {
          return shelf.Response.notFound('Avatar not found');
        }

        return shelf.Response.ok(
          _avatarBytes[idx]!,
          headers: {
            'Content-Type': 'image/jpeg',
            'Cache-Control': 'no-cache',
          },
        );
      });

      // Route : GET /avatars (liste des avatars disponibles)
      router.get('/avatars', (shelf.Request request) {
        final available = _avatarBytes.keys.toList();
        return shelf.Response.ok(
          jsonEncode({'avatars': available}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Démarrer le serveur
      _httpServer = await shelf_io.serve(
        router.call,
        InternetAddress.anyIPv4,
        serverPort.value,
      );

      // Trouver l'IP locale
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      // L'ESP32 SoftAP utilise 192.168.4.1 : privilégier strictement cette
      // interface. Sinon une carte Ethernet/VPN en 192.168.x.x peut être
      // choisie et rendre l'avatar inaccessible depuis Game Area.
      final ipv4 = interfaces
          .expand((interface) => interface.addresses)
          .map((address) => address.address)
          .toList();

      serverIp.value = ipv4.firstWhere(
        (address) => address.startsWith('192.168.4.'),
        orElse: () => ipv4.firstWhere(
          (address) => address.startsWith('192.168.'),
          orElse: () => '',
        ),
      );

      if (serverIp.value.isEmpty) {
        throw StateError(
          'No local IPv4 address found for the ESP32 network. Addresses: $ipv4',
        );
      }

      isServerRunning.value = true;

      if (kDebugMode) {
        print('📸 HTTP Avatar server started:');
        print('   http://${serverIp.value}:${serverPort.value}/avatar/0');
      }
    } catch (e) {
      if (kDebugMode) print('📸 HTTP server error: $e');
      lastError.value = e.toString();
    }
  }

  Future<void> _stopHttpServer() async {
    await _httpServer?.close(force: true);
    _httpServer = null;
    isServerRunning.value = false;
  }

  // ============================================
  // ✅ GET AVATAR URL (pour envoyer au Game Area)
  // ============================================
  String? getAvatarUrl(int playerIndex) {
    if (!_avatarBytes.containsKey(playerIndex)) return null;
    if (serverIp.value.isEmpty) return null;
    // Version empêche le cache réseau de réutiliser une ancienne photo du
    // même index lors d'une partie suivante.
    final version = DateTime.now().millisecondsSinceEpoch;
    return 'http://${serverIp.value}:${serverPort.value}/avatar/$playerIndex?v=$version';
  }

  // ============================================
  // ✅ GET PREVIEW BYTES (pour affichage local)
  // ============================================
  Uint8List? getPreviewBytes(int playerIndex) {
    return _avatarBytes[playerIndex];
  }

  bool hasAvatar(int playerIndex) => _avatarBytes.containsKey(playerIndex);

  // ============================================
  // ✅ CLEAR
  // ============================================
  void clearAllAvatars() {
    _avatarBytes.clear();
    avatarPreviews.clear();
    if (kDebugMode) print('🗑 All avatars cleared from memory');
  }

  void removeAvatar(int playerIndex) {
    _avatarBytes.remove(playerIndex);
    avatarPreviews.remove(playerIndex);
  }

  // ============================================
  // ✅ NEW : Écouter la commande clear depuis Game Area
  // ============================================
  void _listenToClear() {
    try {
      _clearSub = PlatformEventBus.instance.onClearAvatars.listen((_) {
        clearAllAvatars();
        if (kDebugMode) {
          print('🗑 Avatars cleared (requested by Game Area)');
        }
      });
    } catch (_) {}
  }
}