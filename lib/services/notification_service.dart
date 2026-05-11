import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/notification_config.dart';
import '../models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initializeNotifications() async {
    // Demander les permissions de notification
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carryforward: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✓ Notifications activées');
      _setupMessageHandlers();
    }
  }

  void _setupMessageHandlers() {
    // Message en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Message au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu au premier plan: ${message.notification?.title}');
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Message reçu en arrière-plan: ${message.notification?.title}');
  }

  // Envoyer notification au téléchargement
  Future<void> notifyAppDownload(String deviceId, String userId, String userEmail) async {
    try {
      final notification = AppNotification(
        id: const Uuid().v4(),
        type: 'appDownload',
        title: '📱 Nouvelle installation Edumaster IA',
        message: 'L\'application a été téléchargée sur $deviceId. Gain: \$0.15',
        amount: 0.15,
        currency: 'USD',
        timestamp: DateTime.now(),
        metadata: {
          'deviceId': deviceId,
          'userId': userId,
        },
        emailSent: false,
        userEmail: userEmail,
        userId: userId,
      );

      // Sauvegarder en Firestore
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      // Envoyer email à l'admin
      await _sendEmailNotification(notification);

      // Ajouter le gain à votre compte
      await _addEarning(userId, 0.15, 'App Download');
    } catch (e) {
      print('Erreur notification download: $e');
    }
  }

  // Envoyer notification à l'installation complète
  Future<void> notifyAppInstall(String deviceId, String userId, String userEmail) async {
    try {
      final notification = AppNotification(
        id: const Uuid().v4(),
        type: 'appInstall',
        title: '✅ Application installée et lancée',
        message: 'L\'utilisateur a lancé Edumaster IA pour la première fois. Gain: \$0.30',
        amount: 0.30,
        currency: 'USD',
        timestamp: DateTime.now(),
        metadata: {
          'deviceId': deviceId,
          'userId': userId,
        },
        emailSent: false,
        userEmail: userEmail,
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      await _sendEmailNotification(notification);
      await _addEarning(userId, 0.30, 'App Install');
    } catch (e) {
      print('Erreur notification install: $e');
    }
  }

  // Envoyer notification de paiement
  Future<void> notifyPayment(
    String userId,
    String userEmail,
    double amount,
    String paymentMethod,
    String lessonTitle,
  ) async {
    try {
      final notification = AppNotification(
        id: const Uuid().v4(),
        type: 'payment',
        title: '💳 Paiement reçu',
        message: '\$${amount.toStringAsFixed(2)} pour "$lessonTitle" via $paymentMethod. Commission: \$${(amount * 0.70).toStringAsFixed(2)}',
        amount: amount * 0.70, // 70% commission
        currency: 'USD',
        timestamp: DateTime.now(),
        metadata: {
          'userId': userId,
          'paymentMethod': paymentMethod,
          'lessonTitle': lessonTitle,
          'grossAmount': amount,
          'commission': amount * 0.70,
        },
        emailSent: false,
        userEmail: userEmail,
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      await _sendEmailNotification(notification);
      await _addEarning(userId, amount * 0.70, 'Payment');
    } catch (e) {
      print('Erreur notification paiement: $e');
    }
  }

  // Envoyer notification d'abonnement
  Future<void> notifySubscription(
    String userId,
    String userEmail,
    double amount,
    String planName,
  ) async {
    try {
      final notification = AppNotification(
        id: const Uuid().v4(),
        type: 'subscription',
        title: '👑 Nouvel abonnement',
        message: 'Abonnement "$planName" activé. Montant: \$${amount.toStringAsFixed(2)}',
        amount: amount * 0.70,
        currency: 'USD',
        timestamp: DateTime.now(),
        metadata: {
          'userId': userId,
          'planName': planName,
          'amount': amount,
        },
        emailSent: false,
        userEmail: userEmail,
        userId: userId,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      await _sendEmailNotification(notification);
      await _addEarning(userId, amount * 0.70, 'Subscription');
    } catch (e) {
      print('Erreur notification abonnement: $e');
    }
  }

  // Envoyer email à Gmail
  Future<void> _sendEmailNotification(AppNotification notification) async {
    try {
      // Appel à une Cloud Function pour envoyer l'email
      await _firestore.collection('mail').add({
        'to': NotificationConfig.adminEmail,
        'message': {
          'subject': notification.title,
          'html': _buildEmailHtml(notification),
          'text': notification.message,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Marquer comme envoyé
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update({'emailSent': true});

      print('✓ Email envoyé à ${NotificationConfig.adminEmail}');
    } catch (e) {
      print('Erreur envoi email: $e');
    }
  }

  String _buildEmailHtml(AppNotification notification) {
    return '''
      <html>
        <body style="font-family: Arial, sans-serif; background-color: #f5f5f5;">
          <div style="max-width: 600px; margin: 20px auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
            <h2 style="color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px;">${notification.title}</h2>
            <p style="color: #555; font-size: 16px;">${notification.message}</p>
            <div style="background-color: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 10px 0;"><strong>💰 Montant:</strong> \$${notification.amount.toStringAsFixed(2)} ${notification.currency}</p>
              <p style="margin: 10px 0;"><strong>⏰ Date:</strong> ${notification.timestamp.toString()}</p>
              <p style="margin: 10px 0;"><strong>👤 Utilisateur:</strong> ${notification.userEmail}</p>
            </div>
            <hr style="border: 1px solid #ecf0f1;">
            <p style="color: #7f8c8d; font-size: 12px; text-align: center;">
              Dashboard: <a href="https://edumaster-ia.firebaseapp.com/admin/dashboard" style="color: #3498db; text-decoration: none;">Voir les détails</a>
            </p>
          </div>
        </body>
      </html>
    ''';
  }

  // Ajouter les gains au compte
  Future<void> _addEarning(String userId, double amount, String source) async {
    try {
      await _firestore.collection('earnings').add({
        'userId': userId,
        'amount': amount,
        'source': source,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Mettre à jour le total des gains
      await _firestore.collection('users').doc(userId).update({
        'totalEarnings': FieldValue.increment(amount),
        'lastEarningDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur ajout gain: $e');
    }
  }

  // Obtenir les notifications
  Stream<List<AppNotification>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data()))
          .toList();
    });
  }
}