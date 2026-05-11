// Configuration pour les notifications

class NotificationConfig {
  // Gmail de l'administrateur
  static const adminEmail = 'eliastshilombo01@gmail.com';
  
  // Clés Firebase
  static const firebaseProjectId = 'edumaster-ia';
  static const firebaseStorageBucket = 'edumaster-ia.appspot.com';
  
  // Types de notifications
  static const emailTypes = {
    'appDownload': 'Nouveau téléchargement',
    'appInstall': 'Application installée',
    'payment': 'Paiement reçu',
    'subscription': 'Nouvel abonnement',
    'refund': 'Remboursement traité',
    'earning': 'Gains de données',
    'withdrawal': 'Demande de retrait',
    'promo': 'Code promo utilisé',
  };
  
  // Seuils de notification
  static const notifyAfterDownloads = 1; // Chaque téléchargement
  static const notifyAfterPayment = 1; // Chaque paiement
  static const minEarningThreshold = 0.50; // Min $0.50 pour notifier
  
  // Gains par action
  static const gainsPerDownload = 0.15; // $0.15 par téléchargement
  static const gainsPerInstall = 0.30; // $0.30 par installation
  static const gainsPerMBUsed = 0.001; // $0.001 par MB utilisé
  static const gainsPerActiveDay = 0.10; // $0.10 par jour actif
  static const gainsPerVideoView = 0.05; // $0.05 par vidéo regardée
}