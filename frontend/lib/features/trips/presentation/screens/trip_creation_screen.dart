import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:frontend/features/trips/presentation/controllers/trip_creation_provider.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_empty_state.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_error_state.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_request_form.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_result_view.dart';
import 'package:provider/provider.dart';

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripCreationProvider(),
      child: const _TripCreationView(),
    );
  }
}

class _TripCreationView extends StatelessWidget {
  const _TripCreationView();

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
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 380, child: form),
                    const SizedBox(width: 20),
                    Expanded(child: result),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [form, const SizedBox(height: 16), result],
              ),
            );
          },
        );
      },
    );
  }

  void _generate(BuildContext context, TripCreationRequest request) {
    context.read<TripCreationProvider>().generateTrip(request);
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
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Gemini pregateste zilele, activitatile, estimarile de cost si distantele aproximative.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
