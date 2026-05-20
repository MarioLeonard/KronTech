part of '../screens/friends_screen.dart';

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    if (provider.isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.requestsErrorMessage != null && provider.requests.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'We could not load requests',
        message: provider.requestsErrorMessage!,
        actionLabel: 'Reload',
        onAction: provider.loadRequests,
      );
    }

    if (provider.requests.isEmpty) {
      return const _StateCard(
        icon: Icons.inbox_rounded,
        title: 'You do not have new requests',
        message: 'Incoming requests will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 24),
        itemCount: provider.requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = provider.requests[index];
          return _RequestTile(request: request);
        },
      ),
    );
  }
}
