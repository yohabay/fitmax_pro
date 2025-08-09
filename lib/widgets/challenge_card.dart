import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final int progress;
  final int target;
  final int xpReward;
  final VoidCallback onTap;
  final Color backgroundColor;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.progress,
    required this.target,
    required this.xpReward,
    required this.onTap,
    this.backgroundColor = const Color(0xFF2E2E4D),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (progress / target).clamp(0.0, 1.0);

    return Card(
      color: backgroundColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.purpleAccent.shade100.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Daily Challenge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.shade100.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$xpReward XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey.shade800,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$progress / $target completed',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue Challenge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
