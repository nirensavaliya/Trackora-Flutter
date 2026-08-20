import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/data/models/task_model.dart';
import 'package:trackora/screens/tasks/providers/tasks_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksProvider(),
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
                    final list = tasks.visibleTasks;
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _TaskCard(task: list[index]);
                      },
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

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'My Tasks',
            style: TextStyle(
              fontFamily: 'Inter_Bold',
              color: AppColors.appColor,
              fontSize: 26,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: AppColors.textDark, size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 24),
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
              label: 'Pending (${tasks.pendingCount})',
              selected: tasks.selectedTab == TasksTab.pending,
              onTap: () => tasks.selectTab(TasksTab.pending),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Completed (${tasks.completedCount})',
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

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 4),
                Text(
                  '${task.category}  •  ${task.time}',
                  style: const TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                task.priorityLabel,
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: _priorityColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F4EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.statusLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter_Medium',
                    color: AppColors.appColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
