import 'package:flutter/material.dart';

/// A filter button widget used to switch between different todo filters.
///
/// This widget displays a [FilterChip] that can be toggled to show
/// different filtered views of the todo list.
class FilterButton extends StatelessWidget {
  /// The label text displayed on the button.
  final String label;

  /// Whether this filter is currently active.
  final bool isActive;

  /// Callback function when the button is pressed.
  final VoidCallback onPressed;

  /// Creates a [FilterButton].
  const FilterButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onPressed(),
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      selectedColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
      side: BorderSide(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      ),
      showCheckmark: false,
    );
  }
}
