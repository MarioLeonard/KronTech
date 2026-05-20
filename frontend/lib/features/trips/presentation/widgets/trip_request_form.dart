import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/domain/trip_interest.dart';
import 'package:frontend/features/trips/presentation/widgets/city_multi_select_field.dart';
import 'package:frontend/features/trips/presentation/widgets/interest_chips_selector.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_date_range_fields.dart';

part 'trip_request_form_state.dart';
part 'form_card.dart';

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
