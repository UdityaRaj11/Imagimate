class Story {
  final String heading;
  final String text;
  final String type;
  final String? audio;
  final String? imageUrl;
  Story({
    required this.heading,
    required this.text,
    required this.type,
    this.audio,
    this.imageUrl,
  });
}
