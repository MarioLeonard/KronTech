import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/controllers/trip_creation_provider.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_empty_state.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_error_state.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_request_form.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_result_view.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({super.key, this.onBack, this.onTripGenerated});

  final VoidCallback? onBack;
  final VoidCallback? onTripGenerated;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripCreationProvider(),
      child: _TripCreationView(
        onBack: onBack,
        onTripGenerated: onTripGenerated,
      ),
    );
  }
}

class _TripCreationView extends StatelessWidget {
  const _TripCreationView({this.onBack, this.onTripGenerated});

  final VoidCallback? onBack;
  final VoidCallback? onTripGenerated;

  @override
  Widget build(BuildContext context) {
    return Consumer<TripCreationProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final form = TripRequestForm(
              isLoading: provider.isLoading,
              onSubmit: (request) => _generate(context, request),
              onReset: provider.status == TripCreationStatus.idle
                  ? () {}
                  : provider.reset,
            );
            final result = _ResultPanel(provider: provider);

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onBack != null) ...[
                          _BackToTripsButton(onPressed: onBack!),
                          const SizedBox(height: 18),
                        ],
                        const _CreationHeader(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 410, child: form),
                            const SizedBox(width: 24),
                            Expanded(child: result),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (onBack != null) ...[
                        _BackToTripsButton(onPressed: onBack!),
                        const SizedBox(height: 14),
                      ],
                      const _CreationHeader(),
                      const SizedBox(height: 18),
                      form,
                      const SizedBox(height: 16),
                      result,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generate(
    BuildContext context,
    TripCreationRequest request,
  ) async {
    final user = context.read<AuthProvider>().user;
    final idToken = user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesiunea a expirat. Autentifica-te din nou.'),
        ),
      );
      return;
    }

    await context.read<TripCreationProvider>().generateTrip(
      request: request,
      idToken: idToken,
    );
    if (!context.mounted) {
      return;
    }
    if (context.read<TripCreationProvider>().status ==
        TripCreationStatus.success) {
      onTripGenerated?.call();
    }
  }
}

class _CreationHeader extends StatelessWidget {
  const _CreationHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADD TRIP',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Design a route that is ready to use.',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _BackToTripsButton extends StatelessWidget {
  const _BackToTripsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded),
      label: const Text('Back to My Trips'),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.provider});

  final TripCreationProvider provider;

  @override
  Widget build(BuildContext context) {
    switch (provider.status) {
      case TripCreationStatus.idle:
        return const TripEmptyState();
      case TripCreationStatus.loading:
        return const _TripLoadingState();
      case TripCreationStatus.error:
        return TripErrorState(
          message: provider.errorMessage ?? 'Eroare necunoscuta.',
          onRetry: provider.retry,
        );
      case TripCreationStatus.success:
        final trip = provider.trip;
        if (trip == null) {
          return const TripEmptyState();
        }
        return TripResultView(trip: trip);
    }
  }
}

class _TripLoadingState extends StatelessWidget {
  const _TripLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Se genereaza itinerariul...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Gemini is preparing the days, activities, cost estimates, and approximate distances.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.66),
              ),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
