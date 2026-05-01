// lib/widgets/country_dropdown.dart

import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../config/app_theme.dart';

/// Styled dropdown that lets the user choose one of the supported countries.
/// Triggers [onChanged] with the selected ISO 3166-1 alpha-2 country code.
class CountryDropdown extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const CountryDropdown({
    super.key,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DropdownButtonFormField<String>(
        initialValue: selectedCode,
        isExpanded: true,
        dropdownColor: theme.colorScheme.surface,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.public_rounded,
            color: theme.textTheme.labelSmall?.color,
            size: 20,
          ),
          labelText: 'Country',
          labelStyle: theme.textTheme.labelMedium,
        ),
        items: AppConstants.countries
            .map(
              (country) => DropdownMenuItem<String>(
                value: country.code,
                child: Text(
                  country.displayLabel,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null && value != selectedCode) {
            onChanged(value);
          }
        },
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.textTheme.labelSmall?.color,
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
