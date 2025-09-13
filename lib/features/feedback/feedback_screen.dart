import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/feedback_bloc.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For demo, use mock userId and eventId
    const userId = 'user1';
    const eventId = 'event1';
    final TextEditingController commentController = TextEditingController();
    int rating = 5;

    return BlocProvider(
      create: (_) => FeedbackBloc()..add(const FetchEventFeedbacksEvent(eventId: eventId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<FeedbackBloc, FeedbackState>(
                builder: (context, state) {
                  if (state is FeedbackLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EventFeedbacksLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = state.feedbacks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(feedback['userAvatar'] ?? ''),
                                child: feedback['userAvatar'] == null ? const Icon(Icons.person) : null,
                              ),
                              title: Text(feedback['userName'] ?? 'User'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < (feedback['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    )),
                                  ),
                                  Text(feedback['comment'] ?? ''),
                                ],
                              ),
                              trailing: Text(feedback['timestamp']?.substring(0, 10) ?? ''),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is FeedbackError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              Text('Submit Feedback', style: Theme.of(context).textTheme.headlineSmall),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => IconButton(
                          icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                          onPressed: () => setState(() { rating = i + 1; }),
                        )),
                      ),
                      TextField(
                        controller: commentController,
                        decoration: const InputDecoration(labelText: 'Your feedback'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      BlocConsumer<FeedbackBloc, FeedbackState>(
                        listener: (context, state) {
                          if (state is FeedbackSubmitted) {
                            commentController.clear();
                            setState(() { rating = 5; });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback submitted!')),
                            );
                          }
                        },
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is FeedbackSubmitting
                                ? null
                                : () {
                                    final comment = commentController.text.trim();
                                    if (comment.isEmpty) return;
                                    BlocProvider.of<FeedbackBloc>(context).add(
                                      SubmitFeedbackEvent(
                                        userId: userId,
                                        eventId: eventId,
                                        rating: rating,
                                        comment: comment,
                                      ),
                                    );
                                  },
                            child: state is FeedbackSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Submit'),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
