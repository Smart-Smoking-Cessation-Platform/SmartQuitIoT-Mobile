import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/news_detail.dart';
import '../../../providers/news_provider.dart';
import 'video_player.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final int newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(newsDetailViewModelProvider.notifier)
          .loadNewsDetail(widget.newsId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsDetailViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(body: Center(child: Text(state.error!)));
    }

    final news = state.newsDetail!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          news.title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.thumbnail!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              news.content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            for (var media in news.media)
              if (media.mediaType == MediaType.IMAGE)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(media.mediaUrl),
                  ),
                )
              else if (media.mediaType == MediaType.VIDEO)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: VideoPlayerWidget(videoUrl: media.mediaUrl),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
