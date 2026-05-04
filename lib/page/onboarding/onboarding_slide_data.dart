import 'package:flutter/material.dart';

import '../../theme/app_color.dart';

/// Copy and structure from Android `pager_vms1.xml` … `pager_incident.xml`.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.lottieAsset,
    required this.backgroundGradient,
    required this.titleEn,
    required this.titleBm,
    required this.bodyEn,
    required this.bodyBm,
  });

  final String lottieAsset;
  final LinearGradient backgroundGradient;
  final String titleEn;
  final String titleBm;
  final String bodyEn;
  final String bodyBm;
}

abstract final class OnboardingSlides {
  static final List<OnboardingSlideData> all = [
    OnboardingSlideData(
      lottieAsset: 'assets/lottie/vms1.json',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primary.withValues(alpha: 0.12),
          AppColor.white,
        ],
      ),
      titleEn: 'Register visitor faster',
      titleBm: 'Daftar pelawat dengan cepat',
      bodyEn: 'Capture important details of your visitor for better security',
      bodyBm: 'Simpan maklumat pelawat untuk keselamatan kediaman yang lebih baik',
    ),
    OnboardingSlideData(
      lottieAsset: 'assets/lottie/vms2.json',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.primary.withValues(alpha: 0.12),
          AppColor.white,
        ],
      ),
      titleEn: 'Scan QR',
      titleBm: 'Imbas QR',
      bodyEn: 'Check in and check out your visitors instantly',
      bodyBm: 'Daftar masuk dan keluar pelawat anda dengan segera',
    ),
    OnboardingSlideData(
      lottieAsset: 'assets/lottie/attendance.json',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.green.withValues(alpha: 0.18),
          AppColor.white,
        ],
      ),
      titleEn: 'Take your attendance',
      titleBm: 'Ambil kehadiran anda',
      bodyEn: 'Start and end your shift just by taking your own photo',
      bodyBm: 'Mula dan tamatkan syif hanya dengan mengambil gambar anda',
    ),
    OnboardingSlideData(
      lottieAsset: 'assets/lottie/incident.json',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColor.orange.withValues(alpha: 0.15),
          AppColor.white,
        ],
      ),
      titleEn: 'Make a report',
      titleBm: 'Buat laporan',
      bodyEn: 'Skip pen and papers, report incidents on the phone',
      bodyBm: 'Lupakan pen dan kertas, laporkan kejadian melalui telefon anda',
    ),
  ];
}
