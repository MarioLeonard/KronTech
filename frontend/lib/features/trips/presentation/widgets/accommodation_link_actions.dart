part of 'accommodation_card.dart';

class _AccommodationLinkActions extends StatelessWidget {
  const _AccommodationLinkActions({
    required this.bookingUrl,
    required this.airbnbUrl,
  });

  final String bookingUrl;
  final String airbnbUrl;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      if (bookingUrl.isNotEmpty) _BrandLinkButton.booking(url: bookingUrl),
      if (airbnbUrl.isNotEmpty) _BrandLinkButton.airbnb(url: airbnbUrl),
    ];

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330 || buttons.length == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < buttons.length; index++) ...[
                buttons[index],
                if (index != buttons.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              Expanded(child: buttons[index]),
              if (index != buttons.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}
