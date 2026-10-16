import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class SelectorOption<T> {
  final T value;
  final String emoji;
  final String label;
  const SelectorOption(this.value, this.emoji, this.label);
}

/// Chip option row (used for Mood / Time / Location / Energy).
class SelectorRow<T> extends StatelessWidget {
  final String title;
  final List<SelectorOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const SelectorRow({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            title,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = opt.value == selected;
              return ChoiceChip(
                label: Text('${opt.emoji}  ${opt.label}'),
                selected: isSelected,
                onSelected: (_) => onChanged(opt.value),
                showCheckmark: false,
                backgroundColor: pal.surface,
                selectedColor: pal.accent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : pal.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? pal.accent
                      : pal.textSecondary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
