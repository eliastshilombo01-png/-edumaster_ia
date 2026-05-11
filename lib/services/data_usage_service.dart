import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/notification_model.dart';
import '../config/notification_config.dart';
import 'package:uuid/uuid.dart';

class DataUsageService {
  static final DataUsageService _instance = DataUsageService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  factory DataUsageService() {
    return _instance;
  }

  DataUsageService._internal();

  // Tracker la consommation de données
  Future<void> trackDataUsage(String userId, double mbUsed) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      String? deviceModel;
      String? osVersion;

      // Obtenir les infos du device
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        osVersion = androidInfo.version.release;
      } catch (e) {
        deviceModel = 'Unknown';
        osVersion = 'Unknown';
      }

      // Calculer le gain (basé sur les MBs utilisés)
      final earningAmount = mbUsed * NotificationConfig.gainsPerMBUsed;

      // Créer l'enregistrement
      final earning = DataUsageEarning(
        id: const Uuid().v4(),
        userId: userId,
        mbUsed: mbUsed,
        earningAmount: earningAmount,
        timestamp: DateTime.now(),
        appVersion: packageInfo.version,
        deviceModel: deviceModel ?? 'Unknown',
        osVersion: osVersion ?? 'Unknown',
      );

      // Sauvegarder en Firestore
      await _firestore
          .collection('data_usage')
          .doc(earning.id)
          .set(earning.toMap());

      // Ajouter le gain
      if (earningAmount > NotificationConfig.minEarningThreshold) {
        await _addDataUsageEarning(userId, earningAmount);
      }
    } catch (e) {
      print('Erreur track data usage: $e');
    }
  }

  // Ajouter le gain de consommation de données
  Future<void> _addDataUsageEarning(String userId, double amount) async {
    try {
      await _firestore.collection('earnings').add({
        'userId': userId,
        'amount': amount,
        'source': 'Data Usage',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'type': 'data_consumption',
      });

      // Mettre à jour le total
      await _firestore.collection('users').doc(userId).update({
        'totalEarnings': FieldValue.increment(amount),
        'totalDataUsageEarnings': FieldValue.increment(amount),
      });
    } catch (e) {
      print('Erreur ajout data usage earning: $e');
    }
  }

  // Envoyer rapport mensuel
  Future<void> sendMonthlyDataReport(String userId, String userEmail) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      // Récupérer les données du mois
      final query = await _firestore
          .collection('data_usage')
          .where('userId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: monthStart.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: monthEnd.toIso8601String())
          .get();

      double totalMB = 0;
      double totalEarning = 0;

      for (var doc in query.docs) {
        final data = doc.data();
        totalMB += data['mbUsed'] ?? 0;
        totalEarning += data['earningAmount'] ?? 0;
      }

      // Envoyer le rapport par email
      await _firestore.collection('mail').add({
        'to': userEmail,
        'message': {
          'subject': '📊 Rapport mensuel - Gains de consommation de données',
          'html': _buildDataReportHtml(totalMB, totalEarning),
        },
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur envoi rapport: $e');
    }
  }

  String _buildDataReportHtml(double totalMB, double totalEarning) {
    return '''
      <html>
        <body style="font-family: Arial, sans-serif; background-color: #f5f5f5;">
          <div style="max-width: 600px; margin: 20px auto; background-color: white; padding: 20px; border-radius: 8px;">
            <h2 style="color: #2c3e50; border-bottom: 3px solid #27ae60; padding-bottom: 10px;">📊 Rapport Mensuel de Consommation de Données</h2>
            <div style="background-color: #d5f4e6; padding: 20px; border-radius: 5px; margin: 20px 0;">
              <p style="font-size: 24px; color: #27ae60; margin: 0;"><strong>Total MB utilisés: </strong>${totalMB.toStringAsFixed(2)} MB</p>
              <p style="font-size: 20px; color: #27ae60; margin: 10px 0;"><strong>Gains réalisés: </strong>\$${totalEarning.toStringAsFixed(2)}</p>
            </div>
            <p style="color: #555;">Merci d'utiliser Edumaster IA! Continuez à développer votre engagement pour augmenter vos gains.</p>
          </div>
        </body>
      </html>
    ''';
  }
}