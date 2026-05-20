import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/data/backend_trip_generation_service.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/controllers/saved_trips_provider.dart';
import 'package:frontend/features/trips/presentation/screens/trip_creation_screen.dart';
import 'package:frontend/features/trips/presentation/screens/trip_details_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

part '../widgets/my_trips_list_view.dart';
part '../widgets/my_trips_sections.dart';
part '../widgets/my_trips_pending_generation.dart';
part '../widgets/my_trips_cards.dart';
part 'my_trips_screen_state.dart';
part '../widgets/trip_preview_image.dart';
part '../widgets/trip_preview_fallback.dart';
part '../widgets/rounded_hero_flight.dart';
part '../widgets/trips_loading_card.dart';
part '../widgets/trips_error_card.dart';
part '../widgets/trips_empty_card.dart';
part '../widgets/trips_hero.dart';
part '../widgets/trips_section.dart';
part '../widgets/count_pill.dart';
part '../widgets/section_empty_state.dart';
part '../widgets/generating_trip_card.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}
