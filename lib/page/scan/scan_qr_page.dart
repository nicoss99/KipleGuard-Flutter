import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_bar_title_format.dart';
import '../../core/app_logger.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import 'scan_dispatch.dart';
import 'scan_strings.dart';
import 'widget/scan_gallery_bar.dart';
import 'widget/scan_viewfinder_overlay.dart';

/// Android [QRScanActivity] + gallery QR via [MobileScannerController.analyzeImage].
class ScanQrPage extends ConsumerStatefulWidget {
  const ScanQrPage({super.key});

  @override
  ConsumerState<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends ConsumerState<ScanQrPage> {
  late final MobileScannerController _scanner;
  final _picker = ImagePicker();
  var _busy = false;
  var _badScans = 0;
  String? _lastRaw;
  DateTime? _lastAt;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController(
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCamera());
  }

  Future<void> _ensureCamera() async {
    final s = await Permission.camera.request();
    if (!s.isGranted && mounted) {
      await showApiFailedDialog(
        context,
        message: 'Camera permission is required to scan QR codes.',
      );
      if (!mounted) return;
      context.pop();
    }
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  bool _debounce(String raw) {
    final now = DateTime.now();
    if (_lastRaw == raw && _lastAt != null && now.difference(_lastAt!) < const Duration(seconds: 2)) {
      return false;
    }
    _lastRaw = raw;
    _lastAt = now;
    return true;
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final raw = _firstQr(cap);
    if (raw == null || !_debounce(raw)) return;
    await _handleRaw(raw, fromCamera: true);
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    AppLog.track('scan_qr_gallery', screen: 'ScanQr');
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    await _scanner.stop();
    if (!mounted) return;

    var handled = false;
    try {
      final capture = await _scanner.analyzeImage(image.path);
      if (!mounted) return;
      final raw = capture != null ? _firstQr(capture) : null;
      if (raw == null) {
        await showApiFailedDialog(context, message: ScanStrings.noQrInImage);
        return;
      }
      handled = await _handleRaw(raw, fromCamera: false);
    } catch (e, st) {
      AppLog.error('Gallery QR analyze', tag: 'Scan', error: e, stackTrace: st);
      if (mounted) {
        await showApiFailedDialog(context, message: ScanStrings.noQrInImage);
      }
    } finally {
      if (mounted && !handled) await _scanner.start();
    }
  }

  String? _firstQr(BarcodeCapture cap) {
    if (cap.barcodes.isEmpty) return null;
    final raw = cap.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Future<bool> _handleRaw(String raw, {required bool fromCamera}) async {
    _busy = true;
    AppLog.track(fromCamera ? 'scan_qr_detect' : 'scan_qr_gallery_ok', screen: 'ScanQr');
    if (fromCamera) await _scanner.stop();
    if (!mounted) return false;

    var success = false;
    try {
      final result = await ref.read(scanDispatcherProvider).dispatch(raw);
      if (!mounted) return false;
      if (result != null) {
        _apply(result);
        success = true;
        return true;
      }
      _badScans += 1;
      if (_badScans > 3) {
        await showApiFailedDialog(context, message: ScanStrings.unableScanQr);
        if (!mounted) return false;
        context.pop();
        return false;
      }
      return false;
    } catch (e, st) {
      AppLog.error('Scan dispatch', tag: 'Scan', error: e, stackTrace: st);
      if (mounted) await showApiFailedDialog(context, error: e);
      _badScans += 1;
      return false;
    } finally {
      _busy = false;
      if (mounted && fromCamera && !success) await _scanner.start();
    }
  }

  void _apply(ScanDispatch r) {
    switch (r) {
      case ScanDispatchVisitor(:final visitorUuid):
        context.pushReplacement(AppPaths.visitorDetails(visitorUuid));
      case ScanDispatchBooking(:final bookingUuid):
        context.pushReplacement(AppPaths.bookingDetail(bookingUuid));
      case ScanDispatchHealth(:final payload):
        context.pushReplacement(AppRoute.scanHealth.path, extra: payload);
      case ScanDispatchForm(:final applicationUuid):
        context.pushReplacement(AppPaths.scanForm(applicationUuid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(controller: _scanner, fit: BoxFit.cover, onDetect: _onDetect),
            const ScanViewfinderOverlay(),
            _header(),
            ScanGalleryBar(onPickGallery: _pickFromGallery, busy: _busy),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 2,
        color: AppColor.white,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56.h,
            child: Row(
              children: [
                IconButton(
                  onPressed: _busy ? null : () => context.pop(),
                  icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColor.primary),
                ),
                Expanded(
                  child: Text(
                    AppBarTitleFormat.format(ScanStrings.scanQrCode),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: _busy ? null : _pickFromGallery,
                  icon: Icon(Icons.photo_library_outlined, size: 24.sp, color: AppColor.primary),
                  tooltip: ScanStrings.scanFromGallery,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
