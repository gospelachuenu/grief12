class DailyWord {
  final String title;
  final String previewText;
  final String fullText;
  final String date;
  final String? imageUrl;

  DailyWord({
    required this.title,
    required this.previewText,
    required this.fullText,
    required this.date,
    this.imageUrl,
  });

  // Sample data
  static List<DailyWord> getSampleWords() {
    return [
      DailyWord(
        title: 'Finding Peace in God\'s Presence',
        previewText: 'In today\'s fast-paced world, finding moments of peace can seem impossible. Yet, Scripture teaches us that true peace comes from God\'s presence...',
        fullText: '''In today's fast-paced world, finding moments of peace can seem impossible. Yet, Scripture teaches us that true peace comes from God's presence. Psalm 46:10 reminds us to "Be still, and know that I am God." This powerful verse invites us to pause, breathe, and remember who is truly in control.

When we feel overwhelmed by life's challenges, it's essential to remember that God's peace surpasses all understanding. Through prayer, meditation on His Word, and quiet moments in His presence, we can find the tranquility our souls desperately need.

Jesus himself sought quiet moments with the Father, often withdrawing to lonely places to pray. If the Son of God needed these moments of connection, how much more do we need them? In Matthew 11:28, Jesus invites us: "Come to me, all you who are weary and burdened, and I will give you rest."

Today, challenge yourself to carve out time for God. Whether it's early morning, during your lunch break, or before bed, these moments of connection can transform your day and bring the peace that only He can provide.''',
        date: '2024-02-20',
      ),
      DailyWord(
        title: 'Walking in Faith',
        previewText: 'Faith is not just believing in what we cannot see; it\'s taking steps forward even when the path ahead seems uncertain...',
        fullText: '''Faith is not just believing in what we cannot see; it's taking steps forward even when the path ahead seems uncertain. Hebrews 11:1 tells us that "faith is confidence in what we hope for and assurance about what we do not see."

Throughout Scripture, we find countless examples of men and women who stepped out in faith. Abraham left his homeland without knowing where he was going. Moses confronted Pharaoh despite his fears. David faced Goliath armed with only a sling and five stones.

These stories remind us that faith often requires action. It's not enough to simply believe; we must be willing to step out when God calls us. Sometimes this means leaving our comfort zones, facing our fears, or trusting God's plan even when it doesn't make sense to us.

2 Corinthians 5:7 reminds us that "we walk by faith, not by sight." This means trusting God's promises more than our own understanding. When doubts arise, we can draw strength from knowing that God is faithful and His promises are true.

Today, what step of faith is God asking you to take? Remember, you don't need to see the entire path; you just need to take the next step in obedience and trust.''',
        date: '2024-02-19',
      ),
      DailyWord(
        title: 'The Power of Gratitude',
        previewText: 'Gratitude has the power to transform our perspective and bring joy even in challenging circumstances...',
        fullText: '''Gratitude has the power to transform our perspective and bring joy even in challenging circumstances. The Bible repeatedly encourages us to give thanks in all situations, not because everything is perfect, but because God is good and faithful.

1 Thessalonians 5:18 instructs us to "give thanks in all circumstances; for this is God's will for you in Christ Jesus." This doesn't mean we're thankful FOR all circumstances, but rather IN all circumstances. Even in our darkest moments, we can find reasons to be grateful.

Practicing gratitude helps us focus on God's blessings rather than our burdens. It shifts our attention from what we lack to what we have. When we cultivate a grateful heart, we begin to notice the countless ways God provides for us daily.

Research has shown that gratitude can improve our mental health, relationships, and overall well-being. But more importantly, it draws us closer to God's heart. When we acknowledge His goodness in our lives, we develop a deeper trust in His faithfulness.

Consider starting a gratitude journal. Each day, write down three things you're thankful for. They don't have to be big things – sometimes it's the small blessings that make the biggest difference in our lives.''',
        date: '2024-02-18',
      ),
    ];
  }
} 