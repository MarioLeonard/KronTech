import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/domain/trip_interest.dart';
import 'package:frontend/features/trips/presentation/widgets/city_multi_select_field.dart';
import 'package:frontend/features/trips/presentation/widgets/interest_chips_selector.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_date_range_fields.dart';

class TripRequestForm extends StatefulWidget {
  const TripRequestForm({
    required this.onSubmit,
    required this.onReset,
    required this.isLoading,
    super.key,
  });

  final ValueChanged<TripCreationRequest> onSubmit;
  final VoidCallback onReset;
  final bool isLoading;

  @override
  State<TripRequestForm> createState() => _TripRequestFormState();
}

class _TripRequestFormState extends State<TripRequestForm> {
  List<String> _cities = const [];
  DateTime? _startDate;
  DateTime? _endDate;
  Set<TripInterest> _interests = const {};
  String? _validationMessage;

  void _submit() {
    final validationMessage = _validate();
    if (validationMessage != null) {
      setState(() => _validationMessage = validationMessage);
      return;
    }

    setState(() => _validationMessage = null);
    widget.onSubmit(
      TripCreationRequest(
        cities: _cities,
        startDate: _startDate!,
        endDate: _endDate!,
        interests: _interests.toList(),
      ),
    );
  }

  String? _validate() {
    if (_cities.isEmpty) {
      return 'Add at least one city.';
    }
    if (_startDate == null) {
      return 'Choose a start date.';
    }
    if (_endDate == null) {
      return 'Choose an end date.';
    }
    if (_endDate!.isBefore(_startDate!)) {
      return 'The end date cannot be before the start date.';
    }
    if (_interests.isEmpty) {
      return 'Choose at least one interest.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = !widget.isLoading;

    return GlassContainer(
      color: const Color(0xFF0E5A90),
      opacity: 0.22,
      blur: 16,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.9),
                  ),
                  child: const Icon(Icons.route_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a trip',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose the cities, dates, and vibe. AI will turn it into a day-by-day plan.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CityMultiSelectField(
              cities: _cities,
              enabled: enabled,
              onChanged: (cities) {
                setState(() => _cities = cities);
                widget.onReset();
              },
            ),
            const SizedBox(height: 16),
            TripDateRangeFields(
              startDate: _startDate,
              endDate: _endDate,
              enabled: enabled,
              onStartDateChanged: (date) {
                setState(() => _startDate = date);
                widget.onReset();
              },
              onEndDateChanged: (date) {
                setState(() => _endDate = date);
                widget.onReset();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Interests',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            InterestChipsSelector(
              selected: _interests,
              enabled: enabled,
              onChanged: (interests) {
                setState(() => _interests = interests);
                widget.onReset();
              },
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _validationMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: enabled ? _submit : null,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  widget.isLoading
                      ? 'Generating itinerary...'
                      : 'Generate itinerary',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
