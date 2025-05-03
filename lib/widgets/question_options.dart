import 'package:flutter/material.dart';

import 'option_item.dart';

class QuestionOptions extends StatelessWidget {
  final Map<String, String> options;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const QuestionOptions({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final optionLabels = ['A', 'B', 'C', 'D', 'E'];

    return Column(
      children: [
        for (int i = 0; i < optionLabels.length; i++)
          if (options.containsKey(optionLabels[i]))
            OptionItem(
              optionLabel: optionLabels[i],
              optionText: options[optionLabels[i]] ?? '',
              isSelected: selectedOption == optionLabels[i],
              onTap: () => onOptionSelected(optionLabels[i]),
            ),
      ],
    );
  }
}
