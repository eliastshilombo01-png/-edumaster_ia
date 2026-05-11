import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalEarnings = 0;
  int totalDownloads = 0;
  int totalInstalls = 0;
  double totalDataUsageEarnings = 0;
  int totalNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // Charger les gains totaux
      final earningsQuery = await _firestore
          .collection('earnings')
          .get();
      
      double totalEarn = 0;
      for (var doc in earningsQuery.docs) {
        totalEarn += doc.get('amount') ?? 0;
      }

      // Charger les téléchargements
      final downloadsQuery = await _firestore
          .collection('downloads')
          .get();

      // Charger les installations
      final installsQuery = await _firestore
          .collection('installations')
          .get();

      // Charger les notifications
      final notifQuery = await _firestore
          .collection('notifications')
          .get();

      setState(() {
        totalEarnings = totalEarn;
        totalDownloads = downloadsQuery.size;
        totalInstalls = installsQuery.size;
        totalNotifications = notifQuery.size;
      });
    } catch (e) {
      print('Erreur chargement analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Dashboard Analytics'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              _buildStatCard(
                title: 'Gains Totaux',
                value: '\$${totalEarnings.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Downloads Card
              _buildStatCard(
                title: 'Téléchargements',
                value: '$totalDownloads',
                icon: Icons.download,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Installs Card
              _buildStatCard(
                title: 'Installations',
                value: '$totalInstalls',
                icon: Icons.phone_iphone,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Notifications Card
              _buildStatCard(
                title: 'Notifications Envoyées',
                value: '$totalNotifications',
                icon: Icons.notifications,
                color: Colors.purple,
              ),
              const SizedBox(height: 30),

              // Notifications List
              const Text(
                'Dernières Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildNotificationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 5),
              Text(value,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('Aucune notification');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final notif = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.notification_important, color: Colors.deepPurple),
                title: Text(notif['title'] ?? 'Notification'),
                subtitle: Text(notif['message'] ?? ''),
                trailing: Text(
                  '\$${notif['amount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}