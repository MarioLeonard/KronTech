part of '../screens/trip_details_screen.dart';

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
