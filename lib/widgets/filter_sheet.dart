// lib/features/properties/presentation/widgets/filter_sheet.dart

import 'package:flutter/material.dart';

import '../core/entities.dart';
import '../core/localization/app_strings.dart';
import '../core/utils/app_formatters.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.current,
    required this.onApply,
    required this.strings,
  });

  final PropertyFilter current;
  final ValueChanged<PropertyFilter> onApply;
  final AppStrings strings;

  static Future<void> show(
    BuildContext context, {
    required PropertyFilter current,
    required ValueChanged<PropertyFilter> onApply,
    required AppStrings strings,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        current: current,
        onApply: onApply,
        strings: strings,
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late final TextEditingController _locationCtrl;
  RangeValues _priceRange = const RangeValues(0, 50000000);
  int? _minBedrooms;

  static const _maxPrice = 50000000.0;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController(text: widget.current.location ?? '');
    _priceRange = RangeValues(
      widget.current.minPrice ?? 0,
      widget.current.maxPrice ?? _maxPrice,
    );
    _minBedrooms = widget.current.minBedrooms;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  bool get _isActive =>
      _locationCtrl.text.isNotEmpty ||
      _priceRange.start > 0 ||
      _priceRange.end < _maxPrice ||
      _minBedrooms != null;

  void _reset() {
    setState(() {
      _locationCtrl.clear();
      _priceRange = const RangeValues(0, _maxPrice);
      _minBedrooms = null;
    });
  }

  void _apply() {
    widget.onApply(
      PropertyFilter(
        location: _locationCtrl.text.isEmpty ? null : _locationCtrl.text.trim(),
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
        minBedrooms: _minBedrooms,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, mq.viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.filterProperties,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_isActive)
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    strings.reset,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Location
          Text(
            strings.location,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              hintText: strings.cityOrNeighbourhood,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 24),

          // Price range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.priceRange,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatPrice(_priceRange.start)} - ${_formatPrice(_priceRange.end)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: _maxPrice,
            divisions: 30,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 20),

          // Bedrooms
          Text(
            strings.minBedrooms,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _BedroomChip(
                label: strings.any,
                selected: _minBedrooms == null,
                onTap: () => setState(() => _minBedrooms = null),
              ),
              const SizedBox(width: 8),
              for (final n in [1, 2, 3, 4]) ...[
                _BedroomChip(
                  label: '$n+',
                  selected: _minBedrooms == n,
                  onTap: () => setState(() => _minBedrooms = n),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // Apply
          FilledButton(
            onPressed: _apply,
            child: Text('${strings.applyFilter}${_isActive ? ' ●' : ''}'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double v) {
    return AppFormatters.compactBirr(v);
  }
}

class _BedroomChip extends StatelessWidget {
  const _BedroomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
