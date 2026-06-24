import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/fade_slide_in.dart';

// ──────────────────────────────────────────────
//  TrashScreen  – scrollable content area for trash
// ──────────────────────────────────────────────

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trashTasks = context.watch<TaskProvider>().trashTasks;

    if (trashTasks.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Symbols.delete_outline,
          title: 'Trash is empty',
          message: 'Deleted notes and tasks will show up here.',
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: AppColors.surface,
                child: Column(
                  children: [
                    for (int i = 0; i < trashTasks.length; i++) ...[
                      FadeSlideIn(
                        key: ValueKey(trashTasks[i].id),
                        child: _TrashRow(task: trashTasks[i]),
                      ),
                      if (i < trashTasks.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.divider,
                          indent: 0,
                          endIndent: 0,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashRow extends StatelessWidget {
  const _TrashRow({required this.task});
  final Task task;

  void _showRestoreOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Restore Task?',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<TaskProvider>().restoreTask(task.id);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Restore',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<TaskProvider>().deleteTask(task.id);
      },
      background: Container(
        color: AppColors.background,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE04F5F).withAlpha(35),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.delete_forever,
            color: Color(0xFFE04F5F),
            size: 22,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _showRestoreOption(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TrashTaskTitleRow(task: task),
                    const SizedBox(height: 3),
                    _TrashTaskSubtitle(task: task),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Symbols.restore, color: AppColors.textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrashTaskTitleRow extends StatelessWidget {
  const _TrashTaskTitleRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final bool hasPrefix = task.type != TaskType.manual;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasPrefix) ...[
          Icon(task.type.icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 5),
        ],
        Expanded(
          child: Text(
            task.title,
            style: GoogleFonts.inter(
              color: task.isCompleted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TrashTaskSubtitle extends StatelessWidget {
  const _TrashTaskSubtitle({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          task.time,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          task.type.label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
