import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/gallery_bloc.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GalleryBloc()..add(const FetchGalleryEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gallery')),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GalleryLoaded) {
              final items = state.mediaItems;
              if (items.isEmpty) {
                return const Center(child: Text('No gallery items found.'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: item['type'] == 'image'
                              ? Image.asset(
                                  item['thumbnailUrl'] ?? item['url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48),
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      item['thumbnailUrl'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 48),
                                    ),
                                    const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
                                  ],
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is GalleryError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Gallery Screen Placeholder'));
          },
        ),
      ),
    );
  }
}
