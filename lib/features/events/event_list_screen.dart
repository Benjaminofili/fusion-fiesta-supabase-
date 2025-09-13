import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/events_bloc.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsBloc()..add(FetchEventsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Event List')),
        body: BlocBuilder<EventsBloc, EventsState>(
          builder: (context, state) {
            if (state is EventsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventsLoaded) {
              final events = state.events;
              if (events.isEmpty) {
                return const Center(child: Text('No events found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: event['image'] != null
                          ? Image.asset(
                              event['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.event, size: 40),
                            )
                          : const Icon(Icons.event, size: 40),
                      title: Text(event['title'] ?? ''),
                      subtitle: Text(event['description'] ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${event['registered']}/${event['capacity']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailsScreen(eventId: event['id'].toString()),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is EventsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Event List Screen Placeholder', style: TextStyle(fontSize: 24)));
          },
        ),
      ),
    );
  }
}
