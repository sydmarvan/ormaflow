import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../screens/note_editor_screen.dart';
import '../theme/theme.dart';

// ──────────────────────────────────────────────
//  AddTaskBottomSheet
//  Shows three capture options: Add Note, Record Voice, Scan Image.
//  Call via showAddTaskSheet(context).
// ──────────────────────────────────────────────

/// Convenience function – call this instead of constructing the sheet directly.
void showAddTaskSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    // Let the sheet size itself to its content
    isScrollControlled: true,
    // Dim the scrim like the screenshot (nearly black)
    barrierColor: Colors.black.withAlpha(178),
    builder: (_) => const AddTaskBottomSheet(),
  );
}

class AddTaskBottomSheet extends StatelessWidget {
  const AddTaskBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ───────────────────────
            _DragHandle(),
            // ── Option rows ───────────────────────
            _SheetOption(
              icon: Symbols.edit_document,
              label: 'Add Note',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoteEditorScreen(),
                  ),
                );
              },
            ),
            const _SheetDivider(),
            _SheetOption(
              icon: Symbols.mic,
              label: 'Record Voice',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to Record Voice screen
              },
            ),
            const _SheetDivider(),
            _SheetOption(
              icon: Symbols.photo_camera,
              label: 'Scan Image',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to Scan Image screen
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  _DragHandle
// ──────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            // Slightly lighter than the surface so it reads as a handle
            color: const Color(0xFF5A5A5A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  _SheetDivider  – 1 px full-width divider
// ──────────────────────────────────────────────

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 0,
      endIndent: 0,
    );
  }
}

// ──────────────────────────────────────────────
//  _SheetOption  – single tappable row
// ──────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withAlpha(18),
        highlightColor: Colors.white.withAlpha(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Icon in a subtle container box
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
