import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VendorMessagesTab extends StatelessWidget {
  const VendorMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'name': 'Simran Kaur',
        'lastMsg': 'Can we finalize the drone timing for the morning wedding?',
        'time': '10:42 AM',
        'unread': 2,
        'avatar': 'SK',
      },
      {
        'name': 'Rohan Sharma',
        'lastMsg': 'We have sent the advance token payment of ₹15,000.',
        'time': 'Yesterday',
        'unread': 0,
        'avatar': 'RS',
      },
      {
        'name': 'Nitin Verma',
        'lastMsg': 'Please share the preview sample album link.',
        'time': '25 May',
        'unread': 0,
        'avatar': 'NV',
      },
      {
        'name': 'Riwaaz Partner Support',
        'lastMsg': 'Congratulations! Your profile has been featured in top photographers.',
        'time': '20 May',
        'unread': 1,
        'avatar': 'RP',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        separatorBuilder: (context, index) => Divider(
          color: AppColors.grey.withValues(alpha: 0.15),
          height: 1,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final c = chats[index];
          final unread = (c['unread'] as int) > 0;

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: unread
                  ? AppColors.primary
                  : AppColors.gold.withValues(alpha: 0.2),
              child: Text(
                c['avatar'] as String,
                style: TextStyle(
                  color: unread ? AppColors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  c['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  c['time'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: unread ? AppColors.primary : AppColors.grey,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    c['lastMsg'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: unread ? AppColors.black : AppColors.grey,
                      fontWeight:
                          unread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${c['unread']}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat with ${c['name']} opened')),
              );
            },
          );
        },
      ),
    );
  }
}
