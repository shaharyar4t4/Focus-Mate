import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widget/screen_padding.dart';
import '../controller/permission_controller.dart';

class ViewPermission extends StatefulWidget {
  const ViewPermission({super.key});

  @override
  State<ViewPermission> createState() => _ViewPermissionState();
}

class _ViewPermissionState extends State<ViewPermission>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionController>().refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Usage Access and Overlay are granted from system settings outside the
    // app, so re-check whenever the user comes back.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<PermissionController>().refresh();
    }
  }

  void _continue() {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = context.watch<PermissionController>();

    return Scaffold(
      body: SafeArea(
        child: HorizontalPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Almost there!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus Mate needs these permissions to monitor app usage and '
                'block apps once their daily limit is reached.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _PermissionTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Usage Access',
                      description:
                          'Lets Focus Mate measure how long each app is used.',
                      granted: controller.usageAccess,
                      onGrant: controller.requestUsageAccess,
                    ),
                    _PermissionTile(
                      icon: Icons.layers_rounded,
                      title: 'Display Over Other Apps',
                      description:
                          'Shows the blocking screen on top of a limited app.',
                      granted: controller.overlay,
                      onGrant: controller.requestOverlay,
                    ),
                    _PermissionTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notifications',
                      description:
                          'Keeps the monitoring service running in the '
                          'background.',
                      granted: controller.notifications,
                      onGrant: controller.requestNotifications,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.allGranted ? _continue : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    controller.allGranted
                        ? 'Continue'
                        : 'Grant all permissions to continue',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final Future<void> Function() onGrant;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
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
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            granted
                ? Icon(Icons.check_circle, color: Colors.green.shade600)
                : TextButton(
                    onPressed: () => onGrant(),
                    child: const Text('Grant'),
                  ),
          ],
        ),
      ),
    );
  }
}
