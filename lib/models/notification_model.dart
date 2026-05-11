import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type; // appDownload, payment, earning, etc
  final String title;
  final String message;
  final double amount; // Montant en dollars
  final String currency; // USD, CDF
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool emailSent;
  final String userEmail;
  final String userId;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.metadata,
    required this.emailSent,
    required this.userEmail,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'emailSent': emailSent,
      'userEmail': userEmail,
      'userId': userId,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: map['metadata'] ?? {},
      emailSent: map['emailSent'] ?? false,
      userEmail: map['userEmail'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}

class DataUsageEarning {
  final String id;
  final String userId;
  final double mbUsed; // Mégabytes utilisés
  final double earningAmount; // Montant gagné
  final DateTime timestamp;
  final String appVersion;
  final String deviceModel;
  final String osVersion;

  DataUsageEarning({
    required this.id,
    required this.userId,
    required this.mbUsed,
    required this.earningAmount,
    required this.timestamp,
    required this.appVersion,
    required this.deviceModel,
    required this.osVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mbUsed': mbUsed,
      'earningAmount': earningAmount,
      'timestamp': timestamp.toIso8601String(),
      'appVersion': appVersion,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
    };
  }

  factory DataUsageEarning.fromMap(Map<String, dynamic> map) {
    return DataUsageEarning(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      mbUsed: (map['mbUsed'] ?? 0).toDouble(),
      earningAmount: (map['earningAmount'] ?? 0).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      appVersion: map['appVersion'] ?? '',
      deviceModel: map['deviceModel'] ?? '',
      osVersion: map['osVersion'] ?? '',
    );
  }
}

class InstallTracking {
  final String id;
  final String deviceId;
  final String installationDate;
  final String? referralCode;
  final double initialEarning; // Gain pour installation
  final Map<String, dynamic> deviceInfo;
  final String installationSource; // play_store, direct, referral

  InstallTracking({
    required this.id,
    required this.deviceId,
    required this.installationDate,
    this.referralCode,
    required this.initialEarning,
    required this.deviceInfo,
    required this.installationSource,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'installationDate': installationDate,
      'referralCode': referralCode,
      'initialEarning': initialEarning,
      'deviceInfo': deviceInfo,
      'installationSource': installationSource,
    };
  }

  factory InstallTracking.fromMap(Map<String, dynamic> map) {
    return InstallTracking(
      id: map['id'] ?? '',
      deviceId: map['deviceId'] ?? '',
      installationDate: map['installationDate'] ?? '',
      referralCode: map['referralCode'],
      initialEarning: (map['initialEarning'] ?? 0).toDouble(),
      deviceInfo: map['deviceInfo'] ?? {},
      installationSource: map['installationSource'] ?? 'play_store',
    );
  }
}