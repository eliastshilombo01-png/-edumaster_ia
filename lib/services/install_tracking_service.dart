import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../config/notification_config.dart';
import 'notification_service.dart';
import 'package:uuid/uuid.dart';

class InstallTrackingService {
  static final InstallTrackingService _instance = InstallTrackingService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NotificationService _notificationService = NotificationService();

  factory InstallTrackingService() {
    return _instance;
  }

  InstallTrackingService._internal();

  // Tracer la première installation
  Future<void> trackFirstInstall(String userId, String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

      if (isFirstInstall) {
        // Obtenir les infos du device
        final deviceId = await _getDeviceId();
        final deviceInfo = await _getDeviceInfo();

        final tracking = InstallTracking(
          id: const Uuid().v4(),
          deviceId: deviceId,
          installationDate: DateTime.now().toIso8601String(),
          initialEarning: NotificationConfig.gainsPerInstall,
          deviceInfo: deviceInfo,
          installationSource: 'play_store', // Ou direct, ou referral
        );

        // Sauvegarder
        await _firestore
            .collection('installations')
            .doc(tracking.id)
            .set(tracking.toMap());

        // Notifier
        await _notificationService.notifyAppInstall(
          deviceId,
          userId,
          userEmail,
        );

        // Marquer comme installé
        await prefs.setBool('isFirstInstall', false);
        print('✓ Installation trackée et gain envoyé');
      }
    } catch (e) {
      print('Erreur tracking install: $e');
    }
  }

  // Tracer le téléchargement
  Future<void> trackDownload(String userId, String userEmail) async {
    try {
      final deviceId = await _getDeviceId();

      // Créer l'événement de téléchargement
      await _firestore.collection('downloads').add({
        'userId': userId,
        'deviceId': deviceId,
        'downloadDate': FieldValue.serverTimestamp(),
        'appVersion': '1.0.0',
      });

      // Notifier et générer le gain
      await _notificationService.notifyAppDownload(
        deviceId,
        userId,
        userEmail,
      );

      print('✓ Téléchargement tracké');
    } catch (e) {
      print('Erreur tracking download: $e');
    }
  }

  // Obtenir l'ID du device
  Future<String> _getDeviceId() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id; // ID unique du device
    } catch (e) {
      return 'unknown_device';
    }
  }

  // Obtenir les infos du device
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'osVersion': androidInfo.version.release,
        'androidId': androidInfo.id,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'display': androidInfo.display,
        'hardware': androidInfo.hardware,
        'product': androidInfo.product,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Appliquer le code de parrainage
  Future<void> applyReferralCode(
    String userId,
    String userEmail,
    String referralCode,
  ) async {
    try {
      // Récupérer l'utilisateur qui a parraité
      final referrerQuery = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isNotEmpty) {
        final referrerId = referrerQuery.docs.first.id;
        final referrerEmail = referrerQuery.docs.first.get('email');

        // Ajouter gain au parrain
        await _firestore.collection('earnings').add({
          'userId': referrerId,
          'amount': NotificationConfig.gainsPerInstall,
          'source': 'Referral',
          'referredUserId': userId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        // Ajouter gain à l'utilisateur
        await _firestore.collection('earnings').add({
          'userId': userId,
          'amount': 2.00, // Bonus pour l'utilisateur parrainé
          'source': 'Referral Bonus',
          'referrerId': referrerId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        print('✓ Code de parrainage appliqué');
      }
    } catch (e) {
      print('Erreur parrainage: $e');
    }
  }
}