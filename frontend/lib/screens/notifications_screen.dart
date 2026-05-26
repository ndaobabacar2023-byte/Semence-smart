import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    chargerNotifications();
  }

  Future<void> chargerNotifications() async {
    final result = await ApiService.getNotifications();

    if (result["success"] == true) {
      notifications = result["data"];
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text("Aucune notification"),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {

                    final notif = notifications[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: Colors.green,
                        ),
                        title: Text(
                          notif["title"] ?? "",
                        ),
                        subtitle: Text(
                          notif["message"] ?? "",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}