import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:installed_apps/app_info.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/dashboard_controller.dart';
import '../model/app_limit_model.dart';

class ViewDashboard extends StatefulWidget {
  const ViewDashboard({super.key});

  @override
  State<ViewDashboard> createState() => _ViewDashboardState();
}

class _ViewDashboardState extends State<ViewDashboard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Focus Mate'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.init(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'How to use',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.help),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
              ),
              Skeletonizer.sliver(
                enabled: controller.isLoading,
                child: SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver:
                      controller.installedApps.isEmpty && !controller.isLoading
                      ? const SliverFillRemaining(
                          child: Center(child: Text('No apps found.')),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final app = controller.isLoading
                                  ? null
                                  : controller.installedApps[index];
                              final limit = controller.isLoading
                                  ? null
                                  : controller.savedLimits.firstWhere(
                                      (element) =>
                                          element.packageName ==
                                          app?.packageName,
                                      orElse: () => AppLimit(
                                        packageName: app?.packageName ?? '',
                                        appName: app?.name ?? '',
                                        timeLimitInMinutes: 0,
                                      ),
                                    );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                color: colorScheme.surface.withValues(
                                  alpha: 0.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: controller.isLoading
                                      ? null
                                      : () => _showLimitDialog(
                                          context,
                                          app!,
                                          limit!,
                                        ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: app?.icon != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.memory(
                                                    app!.icon!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.android,
                                                  size: 30,
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                app?.name ?? 'Loading App',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if ((limit?.timeLimitInMinutes ??
                                                      0) >
                                                  0)
                                                _UsageProgress(
                                                  used: limit!.usageToday,
                                                  total:
                                                      limit.timeLimitInMinutes,
                                                )
                                              else
                                                Text(
                                                  'No limit set',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          (limit?.timeLimitInMinutes ?? 0) > 0
                                              ? Icons.edit
                                              : Icons.add_circle_outline,
                                          color: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: controller.isLoading
                                ? 10
                                : controller.installedApps.length,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLimitDialog(
    BuildContext context,
    AppInfo app,
    AppLimit currentLimit,
  ) {
    showDialog(
      context: context,
      builder: (context) => _LimitDialog(app: app, currentLimit: currentLimit),
    );
  }
}

/// Dialog to set or remove an app's daily limit. Kept as a StatefulWidget so its
/// TextEditingController is disposed only after the dialog is fully gone —
/// disposing it the instant the route pops crashes the close animation.
class _LimitDialog extends StatefulWidget {
  final AppInfo app;
  final AppLimit currentLimit;

  const _LimitDialog({required this.app, required this.currentLimit});

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.currentLimit.timeLimitInMinutes > 0
          ? widget.currentLimit.timeLimitInMinutes.toString()
          : '',
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final currentLimit = widget.currentLimit;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 28),
          const SizedBox(width: 12),
          const Text('Set Time Limit'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            if (app.icon != null)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(app.icon!, width: 72, height: 72),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              app.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Minutes per day',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: '0',
                suffixText: 'min',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [15, 30, 45, 60, 120].map((mins) {
                return ActionChip(
                  label: Text(
                    '${mins < 60 ? mins : mins ~/ 60}${mins < 60 ? 'm' : 'h'}',
                  ),
                  onPressed: () {
                    setState(() {
                      textController.text = mins.toString();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: textController.text == mins.toString()
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            if (currentLimit.timeLimitInMinutes > 0)
              IconButton(
                onPressed: () {
                  context.read<DashboardController>().removeLimit(
                    app.packageName,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final int? minutes = int.tryParse(textController.text);
                if (minutes != null && minutes > 0) {
                  final newLimit = currentLimit.copyWith(
                    timeLimitInMinutes: minutes,
                    appName: app.name,
                  );
                  context.read<DashboardController>().addOrUpdateLimit(
                    newLimit,
                  );
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shows "used / total min" with a progress bar that turns red once the daily
/// limit is reached.
class _UsageProgress extends StatelessWidget {
  final int used;
  final int total;

  const _UsageProgress({required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool reached = used >= total;
    final double progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final Color barColor = reached ? colorScheme.error : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reached
              ? '$used / $total min · Limit reached'
              : '$used / $total min used',
          style: theme.textTheme.bodySmall?.copyWith(
            color: barColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
