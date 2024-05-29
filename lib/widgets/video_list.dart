import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:imagimate/screens/video_player_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoList extends StatelessWidget {
  final Future<VideoSearchList> videos;

  const VideoList({Key? key, required this.videos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoSearchList>(
      future: videos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No videos found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Video item = snapshot.data![index];
              YoutubePlayerController controller = YoutubePlayerController(
                initialVideoId: item.id.value,
                flags: const YoutubePlayerFlags(
                  hideControls: true,
                  autoPlay: false,
                  mute: false,
                ),
              );

              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoId: item.id.value,
                    ),
                  ),
                ),
                child: Card(
                  color: const Color.fromARGB(255, 113, 146, 143),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                        ),
                        const Divider(),
                        Text(
                          item.title,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
