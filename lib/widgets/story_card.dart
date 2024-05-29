import 'package:flutter/material.dart';
import 'package:imagimate/providers/story.dart';
import 'package:imagimate/screens/stories_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryCard extends StatefulWidget {
  final Story story;
  const StoryCard({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryCard> createState() => _StroyCardState();
}

class _StroyCardState extends State<StoryCard> {

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.story.imageUrl.toString();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          widget.story.heading,
          style: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 189, 84, 84),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          widget.story.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.bubblegumSans(
            color: const Color.fromARGB(255, 111, 63, 63),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: imageUrl != ""
            ? CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage(imageUrl),
              )
            : const CircularProgressIndicator(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryDetailsScreen(story: widget.story),
            ),
          );
        },
      ),
    );
  }
}
