import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VendorEnquiriesTab extends StatefulWidget {
  const VendorEnquiriesTab({super.key});

  @override
  State<VendorEnquiriesTab> createState() => _VendorEnquiriesTabState();
}

class _VendorEnquiriesTabState extends State<VendorEnquiriesTab> {
  final List<Map<String, dynamic>> _enquiries = [
    {
      'name': 'Simran & Aman',
      'service': 'Wedding Photography + Cinematography',
      'budget': '₹75,000',
      'date': '18 Dec 2026',
      'location': 'The Grand Palace, Chandigarh',
      'status': 'New Lead',
      'message':
          'Hi Royal Click team, we love your royal portraits! Are you available for a 2-day wedding in Chandigarh this December?',
      'time': '10 min ago',
    },
    {
      'name': 'Pooja & Rohan',
      'service': 'Pre-Wedding Shoot & Teaser',
      'budget': '₹45,000',
      'date': '04 Nov 2026',
      'location': 'Kasauli Resort, HP',
      'status': 'Responded',
      'message':
          'Looking for scenic candid shoot in mountains with drone coverage.',
      'time': '1 hour ago',
    },
    {
      'name': 'Kavita & Nitin',
      'service': 'Full 3-Day Wedding Coverage',
      'budget': '₹1,20,000',
      'date': '22 Jan 2027',
      'location': 'Hyatt Regency, Ludhiana',
      'status': 'Quote Sent',
      'message':
          'We need complete photography and videography for Mehendi, Sangeet & Reception.',
      'time': 'Yesterday',
    },
    {
      'name': 'Harpreet & Gurjot',
      'service': 'Anand Karaj & Reception',
      'budget': '₹90,000',
      'date': '14 Feb 2027',
      'location': 'Mohali Convention Centre',
      'status': 'New Lead',
      'message': 'Please share availability and customized packages.',
      'time': '2 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: _enquiries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = _enquiries[index];
          final isNew = e['status'] == 'New Lead';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isNew
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.2),
                width: isNew ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          e['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      e['budget'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  e['service'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '"${e['message']}"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 13, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      e['date'],
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.darkGrey),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        e['location'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Instant quote sent to ${e['name']}!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('Send Quote'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Opening WhatsApp chat with ${e['name']}...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 14),
                        label: const Text('WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
