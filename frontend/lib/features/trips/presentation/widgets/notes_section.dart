part of '../screens/trip_details_screen.dart';

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    final notes = [...itinerary.assumptions, ...itinerary.warnings];
    final hasCostNote = itinerary.costSummary.note.isNotEmpty;
    final hasDistanceNote = itinerary.distanceSummary.note.isNotEmpty;
    final hasNotes = hasCostNote || hasDistanceNote || notes.isNotEmpty;

    return _DetailPanel(
      icon: Icons.notes_rounded,
      title: 'Notes',
      subtitle: 'Costs, distances, assumptions, and trip limitations',
      child: !hasNotes
          ? const _EmptySection(message: 'There are no notes for this trip.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasCostNote)
                  _NoteBlock(
                    icon: Icons.payments_rounded,
                    title: 'Cost estimate',
                    text: itinerary.costSummary.note,
                    color: const Color(0xFF7DD3FC),
                  ),
                if (hasDistanceNote)
                  _NoteBlock(
                    icon: Icons.route_rounded,
                    title: 'Distance estimate',
                    text: itinerary.distanceSummary.note,
                    color: const Color(0xFFA7F3D0),
                  ),
                for (var index = 0; index < notes.length; index++)
                  _NoteLine(text: notes[index], index: index),
              ],
            ),
    );
  }
}
