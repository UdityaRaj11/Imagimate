import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 26, 35, 18)),
        backgroundColor: const Color.fromARGB(255, 162, 218, 163),
        title: Text(
          "Video Player",
          style: GoogleFonts.schoolbell(
            color: const Color.fromARGB(255, 26, 35, 18),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/stories-bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: YoutubePlayer(
            controller: _controller,
            onReady: () {
              print('Player is ready.');
            },
            onEnded: (data) {
              print('Video has ended.');
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle toggling between full-screen and normal mode
          _controller.toggleFullScreenMode();
        },
        child: const Icon(Icons.fullscreen),
      ),
    );
  }
}
