import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/data/models/task_model.dart';
import 'package:trackora/screens/tasks/providers/tasks_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksProvider()..loadTasks(),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: _TasksHeader(),
              ),
              const _TasksTabs(),
              Expanded(
                child: Consumer<TasksProvider>(
                  builder: (context, tasks, _) {
                    if (tasks.loading && tasks.tasks.isEmpty) {
                      return const Center(child: AppLoader());
                    }
                    if (tasks.error != null && tasks.tasks.isEmpty) {
                      return _EmptyState(
                        title: 'Could not load tasks',
                        subtitle: tasks.error!,
                        action: 'Retry',
                        onTap: tasks.loadTasks,
                      );
                    }
                    final list = tasks.visibleTasks;
                    if (list.isEmpty) {
                      return const _EmptyState(
                        title: 'No tasks',
                        subtitle: 'Assigned tasks will show up here',
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.appColor,
                      onRefresh: tasks.loadTasks,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _TaskCard(task: list[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.action,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter_SemiBold',
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter_Regular',
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),
            if (action != null && onTap != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onTap,
                child: Text(
                  action!,
                  style: const TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    color: AppColors.appColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'My Tasks',
            style: TextStyle(
              fontFamily: 'Inter_Bold',
              color: AppColors.appColor,
              fontSize: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _TasksTabs extends StatelessWidget {
  const _TasksTabs();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8E6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'All (${tasks.allCount})',
              selected: tasks.selectedTab == TasksTab.all,
              onTap: () => tasks.selectTab(TasksTab.all),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Open (${tasks.pendingCount})',
              selected: tasks.selectedTab == TasksTab.open,
              onTap: () => tasks.selectTab(TasksTab.open),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Done (${tasks.completedCount})',
              selected: tasks.selectedTab == TasksTab.completed,
              onTap: () => tasks.selectTab(TasksTab.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: selected ? 'Inter_SemiBold' : 'Inter_Regular',
                  color: selected ? AppColors.appColor : const Color(0xFF5F6B69),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2.5,
                color: selected ? AppColors.appColor : Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final TaskModel task;

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.high:
        return const Color(0xFFE53935);
      case TaskPriority.medium:
        return const Color(0xFFFB8C00);
      case TaskPriority.low:
        return const Color(0xFF1E88E5);
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.done:
        return AppColors.appColor;
      case TaskStatus.cancelled:
        return const Color(0xFF8A9391);
      case TaskStatus.inProgress:
        return const Color(0xFF1E88E5);
      case TaskStatus.todo:
        return const Color(0xFF5B6CFF);
    }
  }

  Color get _statusBg {
    switch (task.status) {
      case TaskStatus.done:
        return const Color(0xFFE7F4EF);
      case TaskStatus.cancelled:
        return const Color(0xFFEEF1F0);
      case TaskStatus.inProgress:
        return const Color(0xFFE8F3FC);
      case TaskStatus.todo:
        return const Color(0xFFE8ECFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final busy = provider.updatingTaskId == task.id;
    final meta = [
      if (task.leadTitle.isNotEmpty) task.leadTitle,
      if (task.dueLabel.isNotEmpty) 'Due ${task.dueLabel}',
    ].join('  •  ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: task.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(task.icon, color: task.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter_Regular',
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontFamily: 'Inter_Regular',
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.priorityLabel,
                  style: TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    color: _priorityColor,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PopupMenuButton<TaskStatus>(
                enabled: !busy && !provider.updating,
                tooltip: 'Change status',
                onSelected: (status) async {
                  if (status == task.status) return;
                  final ok = await context.read<TasksProvider>().updateStatus(
                    task.id,
                    status,
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.read<TasksProvider>().error ??
                              'Could not update status',
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  for (final status in TaskStatus.values)
                    PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          if (status == task.status)
                            const Icon(Icons.check, size: 16, color: AppColors.appColor)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          Text(
                            _menuLabel(status),
                            style: const TextStyle(
                              fontFamily: 'Inter_Medium',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              task.statusLabel,
                              style: TextStyle(
                                fontFamily: 'Inter_Medium',
                                color: _statusColor,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: _statusColor,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _menuLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To-do';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.done:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}
