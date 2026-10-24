import 'package:flutter/material.dart';

import 'notification_inbox.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => const NotificationInbox(isVendor: false);
}
