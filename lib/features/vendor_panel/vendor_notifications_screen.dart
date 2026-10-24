import 'package:flutter/material.dart';

import '../notifications/notification_inbox.dart';

class VendorNotificationsScreen extends StatelessWidget {
  const VendorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => const NotificationInbox(isVendor: true);
}
