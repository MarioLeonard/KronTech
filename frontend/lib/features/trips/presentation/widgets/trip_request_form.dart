import 'package:flutter/material.dart';
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
      return 'Adauga cel putin un oras.';
    }
    if (_startDate == null) {
      return 'Alege data de inceput.';
    }
    if (_endDate == null) {
      return 'Alege data finala.';
    }
    if (_endDate!.isBefore(_startDate!)) {
      return 'Data finala nu poate fi inainte de data de inceput.';
    }
    if (_interests.isEmpty) {
      return 'Alege cel putin un interes.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = !widget.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiary,
                  child: const Icon(Icons.route_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Creeaza excursie',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            Text('Interese', style: theme.textTheme.titleSmall),
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
              height: 52,
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
                      ? 'Se genereaza itinerariul...'
                      : 'Genereaza excursia',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
