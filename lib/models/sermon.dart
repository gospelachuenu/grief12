class Sermon {
  final String id;
  final String title;
  final String preacher;
  final String date;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  final Duration duration;

  Sermon({
    required this.id,
    required this.title,
    required this.preacher,
    required this.date,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    required this.duration,
  });

  // Sample data
  static List<Sermon> getSampleSermons() {
    return [
      Sermon(
        id: '1',
        title: 'Walking in Faith',
        preacher: 'Pastor Kenneth Achuenu',
        date: '2024-02-20',
        thumbnailUrl: 'assets/images/Walk_in_Faith.png',
        videoUrl: 'assets/Video/Sermon.mp4',
        description: 'A powerful message about walking in faith during challenging times.',
        duration: const Duration(minutes: 16),
      ),
      Sermon(
        id: '2',
        title: 'The Power of Prayer',
        preacher: 'Pastor Sarah',
        date: '2024-02-18',
        thumbnailUrl: 'assets/images/sermon2.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=your_video_id',
        description: 'Understanding the transformative power of prayer in our daily lives.',
        duration: const Duration(minutes: 38),
      ),
      // Add more sample sermons as needed
    ];
  }
} 