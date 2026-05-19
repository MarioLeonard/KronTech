import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/features/trips/domain/trip_activity.dart';
import 'package:frontend/features/trips/domain/trip_day.dart';
import 'package:frontend/features/trips/presentation/widgets/accommodation_card.dart';
import 'package:frontend/features/trips/presentation/widgets/restaurant_card.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({required this.trip, this.onBack, super.key});

  final SavedTrip trip;
  final VoidCallback? onBack;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Map<int, TextEditingController> _dayPlanControllers = {};
  int _selectedSection = 0;

  GeneratedTrip? get _itinerary => widget.trip.itinerary;

  @override
  void initState() {
    super.initState();
    final days = _itinerary?.days ?? const <TripDay>[];
    for (final day in days) {
      _dayPlanControllers[day.dayNumber] = TextEditingController(
        text: _editablePlanFor(day),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _dayPlanControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = _itinerary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 680 ? 16.0 : 32.0;

        return _AdaptiveDetailsScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailsHero(
                    trip: widget.trip,
                    itinerary: itinerary,
                    onBack:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  _AfterHeroSettledFade(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        _SectionToggles(
                          selectedIndex: _selectedSection,
                          onSelected: (index) {
                            setState(() => _selectedSection = index);
                          },
                        ),
                        const SizedBox(height: 20),
                        _DetailsSectionSwitcher(
                          sectionKey: _selectedSection,
                          child: _buildSelectedSection(context, itinerary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedSection(BuildContext context, GeneratedTrip? itinerary) {
    if (itinerary == null) {
      return _DetailPanel(
        icon: Icons.travel_explore_rounded,
        title: 'Trip details',
        subtitle: 'Saved trip overview',
        child: Text(
          widget.trip.summary.isEmpty
              ? 'Details are unavailable for this saved trip.'
              : widget.trip.summary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            height: 1.6,
          ),
        ),
      );
    }

    return switch (_selectedSection) {
      0 => _OverviewSection(trip: widget.trip, itinerary: itinerary),
      1 => _AccommodationSection(itinerary: itinerary),
      2 => _PlacesSection(itinerary: itinerary),
      3 => _EditableScheduleSection(
        itinerary: itinerary,
        controllers: _dayPlanControllers,
      ),
      4 => _RestaurantsSection(itinerary: itinerary),
      _ => _NotesSection(itinerary: itinerary),
    };
  }
}

class _DetailsSectionSwitcher extends StatelessWidget {
  const _DetailsSectionSwitcher({
    required this.sectionKey,
    required this.child,
  });

  final Object sectionKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 560),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        return SizeTransition(
          axisAlignment: -1,
          sizeFactor: animation,
          child: child,
        );
      },
      child: KeyedSubtree(key: ValueKey(sectionKey), child: child),
    );
  }
}

class _AdaptiveDetailsScrollView extends StatelessWidget {
  const _AdaptiveDetailsScrollView({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      child: child,
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({
    required this.trip,
    required this.itinerary,
    required this.onBack,
  });

  final SavedTrip trip;
  final GeneratedTrip? itinerary;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = itinerary?.destinationImageUrl ?? '';
    final title = _destinationLabel(trip);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final heroHeight = isCompact ? 250.0 : 320.0;
        final inset = isCompact ? 20.0 : 30.0;
        final overlay = _AfterHeroSettledFade(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66063970),
                      Color(0x22063970),
                      Color(0xF0063970),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: isCompact ? 14 : 18,
                left: isCompact ? 14 : 18,
                child: _GlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: onBack,
                ),
              ),
              Positioned(
                left: inset,
                right: inset,
                bottom: isCompact ? 22 : 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIP DETAILS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isCompact
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.displaySmall)
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroPill(
                          icon: Icons.calendar_month_rounded,
                          label: _dateRange(trip.startDate, trip.endDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(isCompact ? 22 : 28),
          child: SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: _tripHeroTag(trip),
                  flightShuttleBuilder:
                      (
                        flightContext,
                        animation,
                        flightDirection,
                        fromHeroContext,
                        toHeroContext,
                      ) {
                        return _RoundedHeroFlight(
                          animation: animation,
                          child: _HeroImage(url: imageUrl),
                        );
                      },
                  child: _HeroImage(url: imageUrl),
                ),
                overlay,
              ],
            ),
          ),
        );
      },
    );
  }
}

String _tripHeroTag(SavedTrip trip) {
  return 'trip-image-${trip.id.isEmpty ? trip.title : trip.id}';
}

class _AfterHeroSettledFade extends StatefulWidget {
  const _AfterHeroSettledFade({required this.child});

  final Widget child;

  @override
  State<_AfterHeroSettledFade> createState() => _AfterHeroSettledFadeState();
}

class _AfterHeroSettledFadeState extends State<_AfterHeroSettledFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 140),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeAnimation = ModalRoute.of(context)?.animation;
    if (_routeAnimation == routeAnimation) {
      _syncWithRouteAnimation();
      return;
    }

    _routeAnimation?.removeListener(_syncWithRouteAnimation);
    _routeAnimation?.removeStatusListener(_syncWithRouteStatus);
    _routeAnimation = routeAnimation;
    _routeAnimation?.addListener(_syncWithRouteAnimation);
    _routeAnimation?.addStatusListener(_syncWithRouteStatus);
    _syncWithRouteAnimation();
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_syncWithRouteAnimation);
    _routeAnimation?.removeStatusListener(_syncWithRouteStatus);
    _controller.dispose();
    super.dispose();
  }

  void _syncWithRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.forward();
      return;
    }

    if (status == AnimationStatus.reverse ||
        status == AnimationStatus.dismissed) {
      _controller.reverse();
    }
  }

  void _syncWithRouteAnimation() {
    final animation = _routeAnimation;
    if (animation == null) {
      _controller.forward();
      return;
    }

    if (animation.status == AnimationStatus.reverse) {
      _controller.reverse();
      return;
    }

    if (animation.value >= 0.995) {
      _controller.forward();
      return;
    }

    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final offset = Offset(0, 10 * (1 - progress));

        return IgnorePointer(
          ignoring: progress < 0.95,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(offset: offset, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _RoundedHeroFlight extends StatelessWidget {
  const _RoundedHeroFlight({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final radius = Tween<double>(
          begin: 18,
          end: 28,
        ).transform(Curves.easeInOutCubic.transform(animation.value));

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _SectionToggles extends StatelessWidget {
  const _SectionToggles({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _ToggleItem(Icons.dashboard_rounded, 'Overview'),
    _ToggleItem(Icons.hotel_rounded, 'Accommodation'),
    _ToggleItem(Icons.place_rounded, 'Places'),
    _ToggleItem(Icons.edit_calendar_rounded, 'Schedule'),
    _ToggleItem(Icons.restaurant_rounded, 'Restaurants'),
    _ToggleItem(Icons.notes_rounded, 'Note'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassContainer(
        color: Colors.white,
        opacity: 0.06,
        blur: 14,
        borderRadius: 20,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return _ToggleGrid(
                  items: _items,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                );
              }

              return _ToggleRow(
                items: _items,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const double _gap = 8;
  static const double _height = 46;

  final List<_ToggleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = items.length;
        final selected = selectedIndex.clamp(0, itemCount - 1);
        final itemWidth =
            (constraints.maxWidth - (_gap * (itemCount - 1))) / itemCount;

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                left: selected * (itemWidth + _gap),
                top: 0,
                width: itemWidth,
                height: _height,
                child: const _ToggleSelectionPill(),
              ),
              Row(
                children: [
                  for (var index = 0; index < itemCount; index++) ...[
                    SizedBox(
                      width: itemWidth,
                      height: _height,
                      child: _ToggleButton(
                        item: items[index],
                        isSelected: selected == index,
                        onTap: () => onSelected(index),
                      ),
                    ),
                    if (index != itemCount - 1) const SizedBox(width: _gap),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleGrid extends StatelessWidget {
  const _ToggleGrid({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const int _columns = 2;
  static const double _gap = 8;
  static const double _height = 46;

  final List<_ToggleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selected = selectedIndex.clamp(0, items.length - 1);
        final itemWidth =
            (constraints.maxWidth - (_gap * (_columns - 1))) / _columns;
        final rowCount = (items.length / _columns).ceil();

        return SizedBox(
          height: (rowCount * _height) + ((rowCount - 1) * _gap),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                left: (selected % _columns) * (itemWidth + _gap),
                top: (selected ~/ _columns) * (_height + _gap),
                width: itemWidth,
                height: _height,
                child: const _ToggleSelectionPill(),
              ),
              for (var index = 0; index < items.length; index++)
                Positioned(
                  left: (index % _columns) * (itemWidth + _gap),
                  top: (index ~/ _columns) * (_height + _gap),
                  width: itemWidth,
                  height: _height,
                  child: _ToggleButton(
                    item: items[index],
                    isSelected: selected == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleSelectionPill extends StatelessWidget {
  const _ToggleSelectionPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.tertiary,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ToggleItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final iconColor = Color.lerp(
          Colors.white.withValues(alpha: 0.72),
          Colors.white,
          progress,
        )!;

        return Transform.scale(
          scale: 1 + (0.025 * progress),
          child: Tooltip(
            message: item.label,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: item.label,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 + (2 * progress),
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: 0.08 * progress,
                          child: Transform.scale(
                            scale: 1 + (0.08 * progress),
                            child: Icon(item.icon, size: 18, color: iconColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.78 + (0.22 * progress),
                              ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.trip, required this.itinerary});

  final SavedTrip trip;
  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.dashboard_rounded,
      title: 'Overview',
      subtitle: 'Summary, budget, and quick highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itinerary.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.62,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TripMetricChip(
                icon: Icons.payments_rounded,
                label: 'Estimated total',
                value:
                    '${_number(itinerary.costSummary.estimatedTotal)} ${itinerary.currency}',
              ),
              TripMetricChip(
                icon: Icons.route_rounded,
                label: 'Distance',
                value:
                    '${_number(itinerary.distanceSummary.estimatedTotalKm)} km',
              ),
              TripMetricChip(
                icon: Icons.schedule_rounded,
                label: 'Tranzit',
                value: itinerary.distanceSummary.estimatedTotalTransitDuration,
              ),
              TripMetricChip(
                icon: Icons.calendar_today_rounded,
                label: 'Period',
                value: _dateRange(trip.startDate, trip.endDate),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoGrid(
            children: [
              _InfoTile(
                title: 'Cities',
                value: itinerary.cities.isEmpty
                    ? 'No cities listed'
                    : itinerary.cities.join(', '),
                icon: Icons.location_city_rounded,
              ),
              _InfoTile(
                title: 'Accommodation',
                value:
                    '${_number(itinerary.costSummary.estimatedAccommodationTotal)} ${itinerary.currency}',
                icon: Icons.hotel_rounded,
              ),
              _InfoTile(
                title: 'Activities',
                value:
                    '${_number(itinerary.costSummary.estimatedActivitiesTotal)} ${itinerary.currency}',
                icon: Icons.local_activity_rounded,
              ),
              _InfoTile(
                title: 'Meals',
                value:
                    '${_number(itinerary.costSummary.estimatedFoodTotal)} ${itinerary.currency}',
                icon: Icons.restaurant_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccommodationSection extends StatelessWidget {
  const _AccommodationSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.hotel_rounded,
      title: 'Accommodation',
      subtitle: 'Recommended options and nightly estimates',
      child: itinerary.accommodations.isEmpty
          ? const _EmptySection(
              message: 'There are no saved accommodation options.',
            )
          : _ResponsiveCardList(
              maxColumns: 3,
              minCardWidth: 300,
              children: [
                for (final option in itinerary.accommodations)
                  AccommodationCard(
                    option: option,
                    currency: itinerary.currency,
                  ),
              ],
            ),
    );
  }
}

class _PlacesSection extends StatelessWidget {
  const _PlacesSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    final places = [
      for (final day in itinerary.days)
        for (final activity in day.activities)
          _PlaceItem(
            title: activity.title,
            location: activity.location,
            dayLabel: 'Day ${day.dayNumber}',
            description: activity.description,
          ),
    ];

    return _DetailPanel(
      icon: Icons.place_rounded,
      title: 'Places to visit',
      subtitle: 'Activities and stops extracted from the daily plan',
      child: places.isEmpty
          ? const _EmptySection(message: 'There are no saved places.')
          : _ResponsiveCardList(
              children: [for (final place in places) _PlaceCard(place: place)],
            ),
    );
  }
}

class _EditableScheduleSection extends StatelessWidget {
  const _EditableScheduleSection({
    required this.itinerary,
    required this.controllers,
  });

  final GeneratedTrip itinerary;
  final Map<int, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.edit_calendar_rounded,
      title: 'Daily schedule',
      subtitle: 'Editable plan with activities, costs, and transit',
      trailing: _SmallPill(
        label: 'Editable',
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
      child: itinerary.days.isEmpty
          ? const _EmptySection(message: 'There is no daily schedule.')
          : Column(
              children: [
                for (final day in itinerary.days)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _EditableDayCard(
                      day: day,
                      currency: itinerary.currency,
                      controller: controllers[day.dayNumber]!,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _RestaurantsSection extends StatelessWidget {
  const _RestaurantsSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.restaurant_rounded,
      title: 'Restaurants',
      subtitle: 'Meal suggestions, areas, and estimates',
      child: itinerary.restaurants.isEmpty
          ? const _EmptySection(message: 'There are no saved restaurants.')
          : _ResponsiveCardList(
              children: [
                for (final option in itinerary.restaurants)
                  RestaurantCard(option: option, currency: itinerary.currency),
              ],
            ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    final notes = [...itinerary.assumptions, ...itinerary.warnings];

    return _DetailPanel(
      icon: Icons.notes_rounded,
      title: 'Note',
      subtitle: 'Costs, distances, and limitations saved with the trip',
      child: notes.isEmpty
          ? const _EmptySection(message: 'There are no notes for this trip.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (itinerary.costSummary.note.isNotEmpty)
                  _NoteBlock(
                    icon: Icons.payments_rounded,
                    title: 'Costuri',
                    text: itinerary.costSummary.note,
                  ),
                if (itinerary.distanceSummary.note.isNotEmpty)
                  _NoteBlock(
                    icon: Icons.route_rounded,
                    title: 'Distante',
                    text: itinerary.distanceSummary.note,
                  ),
                for (final note in notes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _NoteLine(text: note),
                  ),
              ],
            ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      color: Colors.white,
      opacity: 0.07,
      blur: 16,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 680 ? 18 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      if (subtitle case final subtitle?) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.58),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResponsiveCardList extends StatelessWidget {
  const _ResponsiveCardList({
    required this.children,
    this.maxColumns = 2,
    this.minCardWidth = 380,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minCardWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth >= 900 ? 14.0 : 12.0;
        final rawColumns = ((constraints.maxWidth + gap) / (minCardWidth + gap))
            .floor();
        final columns = rawColumns.clamp(1, maxColumns).toInt();
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _EditableDayCard extends StatelessWidget {
  const _EditableDayCard({
    required this.day,
    required this.currency,
    required this.controller,
  });

  final TripDay day;
  final String currency;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiary,
                  child: Text(
                    day.dayNumber == 0 ? '?' : day.dayNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.date} · ${day.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TripMetricChip(
                  icon: Icons.payments_rounded,
                  label: 'Cost',
                  value: '${_number(day.estimatedCost)} $currency',
                ),
                TripMetricChip(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${_number(day.estimatedDistanceKm)} km',
                ),
                TripMetricChip(
                  icon: Icons.schedule_rounded,
                  label: 'Transit',
                  value: day.estimatedTransitDuration,
                ),
              ],
            ),
            if (day.summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                day.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                  height: 1.5,
                ),
              ),
            ],
            if (day.activities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SubsectionLabel(
                icon: Icons.local_activity_rounded,
                label: 'Activities',
              ),
              const SizedBox(height: 10),
              _DayActivityPreviewList(day: day, currency: currency),
            ],
            const SizedBox(height: 16),
            _SubsectionLabel(
              icon: Icons.edit_note_rounded,
              label: 'Editable plan',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: null,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                height: 1.55,
              ),
              cursorColor: theme.colorScheme.primary,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF042B55).withValues(alpha: 0.44),
                hintText: 'Edit day plan',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.46),
                ),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final gap = columns == 1 ? 10.0 : 12.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  const _SubsectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 17, color: theme.colorScheme.primary),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayActivityPreviewList extends StatelessWidget {
  const _DayActivityPreviewList({required this.day, required this.currency});

  final TripDay day;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth >= 820;
        final gap = useColumns ? 12.0 : 10.0;
        final width = useColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final activity in day.activities)
              SizedBox(
                width: width,
                child: _ActivityPreviewCard(
                  activity: activity,
                  currency: currency,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActivityPreviewCard extends StatelessWidget {
  const _ActivityPreviewCard({required this.activity, required this.currency});

  final TripActivity activity;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SmallPill(
                label: activity.timeRange,
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  activity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activity.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _TinyMetric(
                icon: Icons.payments_rounded,
                label: _money(activity.estimatedCost, currency),
              ),
              _TinyMetric(
                icon: Icons.commute_rounded,
                label: activity.transportMode,
              ),
              _TinyMetric(
                icon: Icons.schedule_rounded,
                label: activity.travelTimeFromPrevious,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 18),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final _PlaceItem place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.place_rounded,
              color: theme.colorScheme.tertiary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SmallPill(label: place.dayLabel),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  place.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  place.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.74),
          height: 1.42,
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.66)),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _HeroFallback();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _HeroFallback(),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.42),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.26),
            const Color(0xFF063970),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.travel_explore_rounded,
          color: Colors.white,
          size: 70,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF063970).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color:
            color ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ToggleItem {
  const _ToggleItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _PlaceItem {
  const _PlaceItem({
    required this.title,
    required this.location,
    required this.dayLabel,
    required this.description,
  });

  final String title;
  final String location;
  final String dayLabel;
  final String description;
}

String _editablePlanFor(TripDay day) {
  final buffer = StringBuffer()
    ..writeln(day.title)
    ..writeln('${day.date} · ${day.city}')
    ..writeln()
    ..writeln(day.summary);

  for (final activity in day.activities) {
    buffer
      ..writeln()
      ..writeln('${activity.timeRange} - ${activity.title}')
      ..writeln(activity.location)
      ..writeln(activity.description);
  }

  if (day.mealSuggestions.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Meal ideas: ${day.mealSuggestions.join(', ')}');
  }

  return buffer.toString().trim();
}

String _destinationLabel(SavedTrip trip) {
  if (trip.cities.isNotEmpty) {
    return trip.cities.first;
  }
  final itineraryCities = trip.itinerary?.cities ?? const [];
  if (itineraryCities.isNotEmpty) {
    return itineraryCities.first;
  }
  return trip.title;
}

String _dateRange(String startDate, String endDate) {
  final parsedStart = DateTime.tryParse(startDate);
  if (parsedStart == null) {
    return startDate.isEmpty ? 'Date TBC' : startDate;
  }
  final parsedEnd = DateTime.tryParse(endDate);
  if (parsedEnd == null || _isSameDay(parsedStart, parsedEnd)) {
    return _formatTripDate(parsedStart);
  }
  if (parsedStart.year == parsedEnd.year) {
    return '${parsedStart.day} ${_monthAbbreviation(parsedStart.month)}. - ${parsedEnd.day} ${_monthAbbreviation(parsedEnd.month)}. ${parsedEnd.year}';
  }
  return '${_formatTripDate(parsedStart)} - ${_formatTripDate(parsedEnd)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatTripDate(DateTime date) {
  return '${date.day} ${_monthAbbreviation(date.month)}. ${date.year}';
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > months.length) {
    return '';
  }
  return months[month - 1];
}

String _money(num value, String currency) {
  if (value == 0) {
    return 'indisponibil';
  }
  return '${_number(value)} $currency';
}

String _number(num value) {
  if (value == 0) {
    return 'indisponibil';
  }
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
