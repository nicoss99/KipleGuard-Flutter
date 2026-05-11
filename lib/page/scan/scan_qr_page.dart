import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_logger.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import 'scan_dispatch.dart';
import 'scan_strings.dart';
import 'widget/scan_viewfinder_overlay.dart';

/// Android [QRScanActivity] + `activity_qrscan.xml`.
class ScanQrPage extends ConsumerStatefulWidget {
  const ScanQrPage({super.key});

  @override
  ConsumerState<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends ConsumerState<ScanQrPage> {
  late final MobileScannerController _scanner;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to scan QR codes.')),
      );
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
    final codes = cap.barcodes;
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    if (!_debounce(raw)) return;

    _busy = true;
    AppLog.track('scan_qr_detect', screen: 'ScanQr');
    await _scanner.stop();
    if (!mounted) return;

    var navigated = false;
    try {
      final result = await ref.read(scanDispatcherProvider).dispatch(raw);
      if (!mounted) return;
      if (result != null) {
        navigated = true;
        _apply(result);
        return;
      }
      _badScans += 1;
      if (_badScans > 3) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ScanStrings.unableScanQr)));
        context.pop();
        return;
      }
    } catch (e, st) {
      AppLog.error('Scan dispatch', tag: 'Scan', error: e, stackTrace: st);
      _badScans += 1;
    } finally {
      _busy = false;
      if (mounted && !navigated) await _scanner.start();
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
            Positioned(
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
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColor.primary),
                        ),
                        Expanded(
                          child: Text(
                            ScanStrings.scanQrCode,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: 48.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
