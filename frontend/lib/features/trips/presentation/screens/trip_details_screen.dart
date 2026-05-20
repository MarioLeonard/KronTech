import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/friends/data/friends_api_service.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/features/trips/domain/trip_activity.dart';
import 'package:frontend/features/trips/domain/trip_day.dart';
import 'package:frontend/features/trips/presentation/controllers/saved_trips_provider.dart';
import 'package:frontend/features/trips/presentation/widgets/accommodation_card.dart';
import 'package:frontend/features/trips/presentation/widgets/restaurant_card.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

part '../widgets/trip_details_layout.dart';
part '../widgets/trip_details_sections.dart';
part '../widgets/trip_details_schedule_widgets.dart';
part '../widgets/trip_details_support_widgets.dart';
part 'trip_details_screen_state.dart';
part '../widgets/adaptive_details_scroll_view.dart';
part '../widgets/details_hero.dart';
part '../widgets/after_hero_settled_fade.dart';
part '../widgets/after_hero_settled_fade_state.dart';
part '../widgets/details_rounded_hero_flight.dart';
part '../widgets/section_toggles.dart';
part '../widgets/toggle_row.dart';
part '../widgets/toggle_grid.dart';
part '../widgets/toggle_selection_pill.dart';
part '../widgets/toggle_button.dart';
part '../widgets/schedule_day_view.dart';
part '../widgets/schedule_stat.dart';
part '../widgets/schedule_timeline.dart';
part '../widgets/schedule_timeline_item.dart';
part '../widgets/accommodation_section.dart';
part '../widgets/trip_friends_section.dart';
part '../widgets/trip_friend_tile.dart';
part '../widgets/add_trip_friend_sheet.dart';
part '../widgets/add_trip_friend_sheet_state.dart';
part '../widgets/trip_sheet_card.dart';
part '../widgets/friend_picker_row.dart';
part '../widgets/places_section.dart';
part '../widgets/editable_schedule_section.dart';
part '../widgets/editable_schedule_section_state.dart';
part '../widgets/restaurants_section.dart';
part '../widgets/notes_section.dart';
part '../widgets/detail_panel.dart';
part '../widgets/responsive_card_list.dart';
part '../widgets/staggered_section_item.dart';
part '../widgets/staggered_section_item_state.dart';
part '../widgets/tiny_metric.dart';
part '../widgets/info_tile.dart';
part '../widgets/place_card.dart';
part '../widgets/visited_checkbox.dart';
part '../widgets/note_block.dart';
part '../widgets/note_line.dart';
part '../widgets/empty_section.dart';
part '../widgets/hero_image.dart';
part '../widgets/hero_fallback.dart';
part '../widgets/glass_icon_button.dart';
part '../widgets/hero_pill.dart';
part '../widgets/small_pill.dart';
part '../widgets/toggle_item.dart';
part '../widgets/place_item.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({required this.trip, this.onBack, super.key});

  final SavedTrip trip;
  final VoidCallback? onBack;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}
