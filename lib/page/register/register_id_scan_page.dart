import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widget/app_progress_indicator.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import 'register_id_ocr_parser.dart';
import 'register_strings.dart';
import 'register_visitor_draft.dart';
import 'widget/register_scan_overlay.dart';
import 'widget/register_styled_header.dart';

/// Ports Android `Camera2Activity` + `GoogleTextRecognizer` using ML Kit on camera frames.
class RegisterIdScanPage extends StatefulWidget {
  const RegisterIdScanPage({super.key});

  @override
  State<RegisterIdScanPage> createState() => _RegisterIdScanPageState();
}

class _RegisterIdScanPageState extends State<RegisterIdScanPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  CameraController? _camera;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Timer? _timer;
  var _busy = false;
  var _torch = false;
  var _othersSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
    _initCam();
  }

  Future<void> _initCam() async {
    final perm = await Permission.camera.request();
    if (!perm.isGranted || !mounted) {
      if (mounted) context.pop();
      return;
    }
    final cams = await availableCameras();
    if (cams.isEmpty || !mounted) return;
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    final controller = CameraController(back, ResolutionPreset.medium, enableAudio: false);
    try {
      await controller.initialize();
    } catch (_) {
      if (mounted) context.pop();
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _camera = controller);
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) => _tick());
  }

  Future<void> _setTorch(bool on) async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) return;
    try {
      await cam.setFlashMode(on ? FlashMode.torch : FlashMode.off);
      setState(() => _torch = on);
    } catch (_) {}
  }

  Future<void> _tick() async {
    final cam = _camera;
    if (_busy || cam == null || !cam.value.isInitialized || !mounted) return;
    _busy = true;
    try {
      final shot = await cam.takePicture();
      final input = InputImage.fromFilePath(shot.path);
      final recognized = await _recognizer.processImage(input);
      final raw = recognized.text;
      try {
        await File(shot.path).delete();
      } catch (_) {}

      if (!mounted || raw.isEmpty) return;

      final idx = _tabs.index;
      if (idx == 0) {
        final r = registerOcrParseMyKad(raw);
        if (r != null && r.ic12 != null) {
          _timer?.cancel();
          context.pop(RegisterIdScanResult(ic12: r.ic12, name: r.name));
        }
      } else if (idx == 1) {
        final r = registerOcrParseLicense(raw);
        if (r != null && r.ic12 != null) {
          _timer?.cancel();
          context.pop(RegisterIdScanResult(ic12: r.ic12, name: r.name));
        }
      } else {
        await _maybeShowOthers(raw);
      }
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  Future<void> _maybeShowOthers(String raw) async {
    if (_othersSheetOpen || !mounted) return;
    final tokens = registerOcrTokenizeOthers(raw);
    final ids = registerOcrFind12DigitIds(raw);
    final choices = <String>{...ids, ...tokens}.toList();
    if (choices.length < 2) return;
    _othersSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(RegisterStrings.scanPickToken, style: AppTextStyle.subtitle),
              ),
              ...choices.map(
                (e) => ListTile(
                  title: Text(e, style: AppTextStyle.body),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    final ic = RegExp(r'^\d{12}$').hasMatch(e) ? e : null;
                    if (context.mounted) {
                      _timer?.cancel();
                      context.pop(RegisterIdScanResult(ic12: ic, name: ic == null ? e : null));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => _othersSheetOpen = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabs.dispose();
    _camera?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cam = _camera;
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegisterStyledHeader(
            title: RegisterStrings.scanTitle,
            onBack: () => context.pop(),
          ),
          Material(
            color: AppColor.white,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColor.textPrimary,
              unselectedLabelColor: AppColor.textSecondary,
              indicatorColor: AppColor.textPrimary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'MyKad'),
                Tab(text: 'License'),
                Tab(text: 'Others'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: cam == null || !cam.value.isInitialized
                      ? const Center(child: AppProgressIndicator())
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              child: AspectRatio(
                                aspectRatio: cam.value.aspectRatio,
                                child: CameraPreview(cam),
                              ),
                            ),
                            const Positioned.fill(child: RegisterScanOverlay()),
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: () => _setTorch(!_torch),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: AppColor.onPrimary,
                          minimumSize: Size(double.infinity, 44.h),
                        ),
                        child: Text(_torch ? RegisterStrings.scanLightOff : RegisterStrings.scanLightOn),
                      ),
                      SizedBox(height: 8.h),
                      Text(RegisterStrings.scanAlignHint, style: AppTextStyle.bodyMuted, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
