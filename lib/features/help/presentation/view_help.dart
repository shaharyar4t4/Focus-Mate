import 'package:flutter/material.dart';

class ViewHelp extends StatelessWidget {
  const ViewHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [
          _SectionTitle('Getting Started'),
          _Step(
            number: 1,
            title: 'Grant permissions',
            body:
                'On first launch, allow Usage Access, Display over other apps, '
                'and Notifications. Focus Mate cannot track or block apps '
                'without these.',
          ),
          _Step(
            number: 2,
            title: 'Pick an app',
            body:
                'On the dashboard, find the app you want to limit (use the '
                'search bar to find it quickly) and tap it.',
          ),
          _Step(
            number: 3,
            title: 'Set a daily limit',
            body:
                'Type the minutes per day, or tap a quick option (15m, 30m, '
                '1h…), then press Save. The app card now shows your usage and '
                'a progress bar.',
          ),
          _Step(
            number: 4,
            title: 'Stay focused',
            body:
                'When you reach the limit, Focus Mate plays an alert, shows a '
                '“Time’s Up” screen over the app, and sends you back to the '
                'home screen.',
            isLast: true,
          ),

          SizedBox(height: 24),
          _SectionTitle('Managing Limits'),
          _InfoCard(
            icon: Icons.edit_outlined,
            title: 'Change or remove a limit',
            body:
                'Tap an app again to change its minutes, or tap the delete '
                'icon in the dialog to remove the limit completely.',
          ),
          _InfoCard(
            icon: Icons.refresh,
            title: 'Refresh usage',
            body:
                'Usage stats update every few minutes. Tap the refresh icon on '
                'the dashboard to pull the latest numbers right away.',
          ),

          SizedBox(height: 24),
          _SectionTitle('About the notifications'),
          _InfoCard(
            icon: Icons.shield_outlined,
            title: '“Monitoring app usage…” — keep this on',
            body:
                'This permanent, silent notification is required by Android to '
                'keep Focus Mate running in the background. It is what lets '
                'blocking work even after you close the app — please don’t '
                'turn it off. It stays quietly at the bottom of your '
                'notifications and won’t disturb you.',
          ),
          _InfoCard(
            icon: Icons.alarm,
            title: '“Time’s Up!” — the alert',
            body:
                'This one plays a sound and vibrates when an app hits its '
                'limit. You can swipe it away after seeing it.',
            isLast: true,
          ),

          SizedBox(height: 24),
          _InfoCard(
            icon: Icons.battery_saver,
            title: 'Tip: disable battery optimization',
            body:
                'On some phones (Xiaomi, Oppo, Vivo, Samsung…) the system may '
                'stop background apps. If blocking ever stops working, exclude '
                'Focus Mate from battery optimization in your phone settings.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final bool isLast;

  const _Step({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
