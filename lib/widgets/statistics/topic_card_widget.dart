import 'package:flutter/material.dart';

class TopicCardWidget extends StatelessWidget {
  const TopicCardWidget({super.key, required this.topic});

  final Map<String, dynamic> topic;

  @override
  Widget build(BuildContext context) {
    final status = topic['status'] as String;
    final percentage = topic['percentage'] as int;

    // Set icon and color based on status
    IconData statusIcon;
    Color statusColor;

    if (status == 'strong') {
      statusIcon = Icons.local_fire_department;
      statusColor = const Color(0xFF2E7D32);
    } else if (status == 'developing') {
      statusIcon = Icons.extension;
      statusColor = const Color(0xFFFFC107);
    } else {
      statusIcon = Icons.psychology;
      statusColor = const Color(0xFFD32F2F);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: statusColor.withAlpha(50), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  statusColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '%$percentage',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.refresh, size: 16),
                //   style: IconButton.styleFrom(
                //     foregroundColor: statusColor,
                //     padding: const EdgeInsets.all(4),
                //     minimumSize: const Size(24, 24),
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
