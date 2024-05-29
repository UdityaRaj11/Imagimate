import 'package:flutter/material.dart';
import 'package:imagimate/providers/story.dart';
import 'package:imagimate/widgets/story_card.dart';

class ReadableList extends StatelessWidget {
  final List<Story> stories;
  const ReadableList({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg1.jpeg'), fit: BoxFit.cover)),
      child: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          Story story = stories[index];
          return StoryCard(story: story);
        },
      ),
    );
  }
}
