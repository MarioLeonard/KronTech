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
    this.onClose,
    super.key,
  });

  final ValueChanged<TripCreationRequest> onSubmit;
  final VoidCallback onReset;
  final bool isLoading;
  final VoidCallback? onClose;

  @override
  State<TripRequestForm> createState() => _TripRequestFormState();
}

class _TripRequestFormState extends State<TripRequestForm> {
  List<String> _cities = const [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOneDayTrip = false;
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
        endDate: _isOneDayTrip ? _startDate! : _endDate!,
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
    if (!_isOneDayTrip && _endDate == null) {
      return 'Choose an end date.';
    }
    if (!_isOneDayTrip && _endDate!.isBefore(_startDate!)) {
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
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FormCard(
              child: CityMultiSelectField(
                cities: _cities,
                enabled: enabled,
                onChanged: (cities) {
                  setState(() => _cities = cities);
                  widget.onReset();
                },
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              child: TripDateRangeFields(
                startDate: _startDate,
                endDate: _endDate,
                isOneDayTrip: _isOneDayTrip,
                enabled: enabled,
                onStartDateChanged: (date) {
                  setState(() {
                    _startDate = date;
                    if (_endDate != null && _endDate!.isBefore(date)) {
                      _endDate = null;
                    }
                  });
                  widget.onReset();
                },
                onEndDateChanged: (date) {
                  setState(() => _endDate = date);
                  widget.onReset();
                },
                onOneDayTripChanged: (value) {
                  setState(() {
                    _isOneDayTrip = value;
                    if (value) {
                      _endDate = null;
                    }
                  });
                  widget.onReset();
                },
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              title: 'Trip vibe',
              child: InterestChipsSelector(
                selected: _interests,
                enabled: enabled,
                onChanged: (interests) {
                  setState(() => _interests = interests);
                  widget.onReset();
                },
              ),
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
                      ? 'Building your itinerary...'
                      : 'Create my itinerary',
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

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
