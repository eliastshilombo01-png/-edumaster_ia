# 📧 Guide Complet - Système de Notifications et Monétisation

## 🎯 Que Fait Ce Système?

### 1. **Notifications Email Automatiques** ✉️
- Chaque téléchargement → Email à votre Gmail
- Chaque installation → Email à votre Gmail  
- Chaque paiement → Email avec détails
- Chaque gain → Email avec le montant

### 2. **Gains par Téléchargement** 💰
- **$0.15** par téléchargement de l'app
- Automatiquement ajouté à votre compte
- Tracké dans Firebase Firestore

### 3. **Gains par Installation** 📱
- **$0.30** par première installation
- Détection automatique de la 1ère utilisation
- Bonus unique par appareil

### 4. **Gains par Consommation de Données** 📊
- **$0.001** par MB utilisé
- Tracké automatiquement en arrière-plan
- Convertit la consommation en revenue

### 5. **Gains par Paiements** 💳
- **70% de commission** sur chaque leçon achetée
- Email immédiat à chaque paiement
- Retraits automatiques tous les mois

---

## 📋 Installation

### Étape 1: Ajouter les Dépendances

```bash
flutter pub add firebase_core firebase_messaging cloud_firestore
flutter pub add device_info_plus package_info_plus
flutter pub add shared_preferences uuid http
flutter pub add google_mobile_ads
```

### Étape 2: Configurer Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un nouveau projet: **edumaster-ia**
3. Ajouter une app Android
4. Télécharger `google-services.json`
5. Placer dans `android/app/`

### Étape 3: Configurer Firestore

1. Aller à **Firestore Database**
2. Créer une nouvelle base de données
3. Commencer en mode **Test** (temporaire)
4. Créer les collections:
   - `users`
   - `notifications`
   - `downloads`
   - `installations`
   - `earnings`
   - `data_usage`
   - `mail`

### Étape 4: Configurer les Emails

1. Installer **Firebase Extensions**
2. Chercher **Trigger Email from Firestore**
3. Installer l'extension
4. Connecter Gmail (eliastshilombo01@gmail.com)
5. Autoriser Firebase à envoyer des emails

### Étape 5: Activer Firebase Cloud Messaging

1. Aller à **Cloud Messaging**
2. Copier **Server Key**
3. Utiliser dans les notifications push

---

## 💻 Code d'Intégration

### Lors du Démarrage de l'App:

```dart
import 'services/install_tracking_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialiser les notifications
  final notif = NotificationService();
  await notif.initializeNotifications();
  
  // Tracer l'installation
  final tracking = InstallTrackingService();
  await tracking.trackFirstInstall(userId, userEmail);
  
  runApp(const MyApp());
}
```

### Lors d'un Paiement:

```dart
final notif = NotificationService();
await notif.notifyPayment(
  userId,
  userEmail,
  amount: 4.99,
  paymentMethod: 'M-Pesa',
  lessonTitle: 'Intelligence Artificielle - Leçon 1',
);
```

### Pour Tracker la Consommation de Données:

```dart
final dataUsage = DataUsageService();
await dataUsage.trackDataUsage(userId, mbUsed: 25.5);
```

---

## 📊 Structure Firebase

### Collection: `notifications`
```json
{
  "id": "uuid",
  "type": "appDownload",
  "title": "📱 Nouvelle installation",
  "message": "...",
  "amount": 0.15,
  "currency": "USD",
  "timestamp": "2024-01-15T10:30:00Z",
  "emailSent": true,
  "userEmail": "user@example.com",
  "userId": "user123"
}
```

### Collection: `downloads`
```json
{
  "userId": "user123",
  "deviceId": "device_id",
  "downloadDate": "2024-01-15T10:30:00Z",
  "appVersion": "1.0.0"
}
```

### Collection: `installations`
```json
{
  "id": "uuid",
  "deviceId": "device_id",
  "installationDate": "2024-01-15T10:30:00Z",
  "initialEarning": 0.30,
  "deviceInfo": { /* infos device */ },
  "installationSource": "play_store"
}
```

### Collection: `earnings`
```json
{
  "userId": "user123",
  "amount": 0.15,
  "source": "App Download",
  "timestamp": "2024-01-15T10:30:00Z",
  "status": "pending"
}
```

---

## 🎯 Flux des Gains

```
┌─────────────────┐
│ Utilisateur     │
│ télécharge app  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ trackDownload() appelé  │
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Sauvegarde en Firestore      │
│ + Envoie email admin         │
│ + Ajoute gain ($0.15)        │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────┐
│ Email reçu à Gmail ✓     │
│ Gain enregistré ✓        │
│ Montant: $0.15 ✓         │
└──────────────────────────┘
```

---

## 💰 Projections Financières

### Scénario 1 : 100 utilisateurs
- 100 téléchargements: **$15**
- 80 installations: **$24**
- 50 paiements ($4.99 × 70%): **$175**
- Consommation données: **$10**
- **TOTAL: $224/mois**

### Scénario 2: 1000 utilisateurs
- 1000 téléchargements: **$150**
- 800 installations: **$240**
- 500 paiements: **$1,750**
- Consommation données: **$100**
- **TOTAL: $2,240/mois**

### Scénario 3: 10000 utilisateurs
- **TOTAL: $22,400/mois** 🚀

---

## 🔧 Configuration Gmail

1. Aller à [Gmail Security](https://myaccount.google.com/security)
2. Activer **2-Factor Authentication**
3. Créer un **App Password**
4. Copier dans Firebase Extension

---

## 📱 Permission Android

Ajouter dans `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.GET_TASKS" />
```

---

## ✅ Checklist de Déploiement

- [ ] Firebase configuré
- [ ] Firestore créé
- [ ] Gmail connecté
- [ ] Extensions Firebase installées
- [ ] Dépendances pub ajoutées
- [ ] Code intégré dans main.dart
- [ ] Permissions ajoutées
- [ ] Testé localement
- [ ] Déployé sur Play Store
- [ ] Premiers gains reçus ✓

---

## 🚀 Vous êtes Prêt!

Chaque téléchargement, installation et paiement génère maintenant des gains et des notifications email automatiques! 💰📧
