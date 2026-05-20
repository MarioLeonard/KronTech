import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/data/backend_saved_trips_service.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_request_form.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/hive_service.dart';
import 'package:provider/provider.dart';

part 'trip_creation_view.dart';
part 'trip_generation_paywall_dialog.dart';
part 'paywall_feature.dart';

typedef TripGenerationRequestHandler =
    Future<void> Function(
      TripCreationRequest request,
      String idToken,
      String userId,
    );

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({
    super.key,
    this.onBack,
    this.onTripGenerationRequested,
  });

  final VoidCallback? onBack;
  final TripGenerationRequestHandler? onTripGenerationRequested;

  @override
  Widget build(BuildContext context) {
    return _TripCreationView(
      onBack: onBack,
      onTripGenerationRequested: onTripGenerationRequested,
    );
  }
}
