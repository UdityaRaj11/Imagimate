import 'package:flutter/material.dart';
import 'package:imagimate/providers/story.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryDetailsScreen extends StatefulWidget {
  final Story story;

  const StoryDetailsScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  late AudioPlayer audioPlayer;
  double currentPosition = 0.0;
  double totalDuration = 1.0;
  bool audioloading = false;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        currentPosition = duration.inSeconds.toDouble();
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration.inSeconds.toDouble();
      });
    });
  }

  Future<void> _playPause() async {
    String downloadURL = widget.story.audio.toString();

    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      setState(() {
        audioloading = true;
      });
      await audioPlayer.play(UrlSource(downloadURL)).then((value) => {
            setState(() {
              audioloading = false;
            })
          });
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _seek(double seconds) {
    audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.story.imageUrl.toString();
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 26, 35, 18)),
        backgroundColor: const Color.fromARGB(255, 162, 218, 163),
        title: Text(
          "ImagiMate",
          style: GoogleFonts.schoolbell(
            color: const Color.fromARGB(255, 26, 35, 18),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 154, 255, 155),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/stories-bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                if (widget.story.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      color: Color.fromARGB(255, 55, 105, 64),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                const SizedBox(height: 16),
                if (widget.story.audio != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 40,
                          color: Color.fromARGB(255, 55, 105, 64),
                        ),
                        onPressed: () {
                          _seek(currentPosition -
                              10.0); // Move backward 10 seconds
                        },
                      ),
                      audioloading
                          ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 55, 105, 64),
                            )
                          : IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_arrow,
                                size: 50,
                                color: const Color.fromARGB(255, 55, 105, 64),
                              ),
                              onPressed: _playPause,
                            ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          size: 40,
                          color: Color.fromARGB(255, 55, 105, 64),
                        ),
                        onPressed: () {
                          _seek(currentPosition +
                              10.0); // Move forward 10 seconds
                        },
                      ),
                    ],
                  ),

                // Seek bar
                Slider(
                  activeColor: const Color.fromARGB(255, 55, 105, 64),
                  value: currentPosition,
                  max: totalDuration,
                  onChanged: (value) {
                    _seek(value);
                  },
                ),
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: const Color.fromARGB(255, 162, 218, 163),
                    child: Column(
                      children: [
                        Text(
                          widget.story.heading,
                          style: GoogleFonts.montserrat(
                            color: const Color.fromARGB(255, 48, 65, 33),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.story.text,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.bubblegumSans(
                            color: const Color.fromARGB(255, 55, 105, 64),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
