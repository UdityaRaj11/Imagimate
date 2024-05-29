import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart' as OI;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AudioPlayer audioPlayer;
  double currentPosition = 0.0;
  double totalDuration = 1.0;
  bool audioloading = false;

  bool isPlaying = false;
  final List<ChatMessage> _messages = [];
  String? latestMessage;
  List<Messages> chats = [];
  bool _isLoading = false;
  String audioPath = '';
  int? latestTokenCount;
  bool loadingAudio = false;
  bool reachedAudioLimit = false;
  bool reachedTextLimit = false;
  bool _showControls = false;
  final _textController = TextEditingController();
  var _enteredMessage = '';
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['OPENAI_API_KEY'],
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  Future<void> _checkLimits() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.data()!['textTokens'] >= 20000) {
        setState(() {
          reachedTextLimit = true;
        });
      }
      if (value.data()!['audioTokens'] >= 20000) {
        setState(() {
          reachedAudioLimit = true;
        });
      }
    });
  }

  Future<void> _postTextTokensUsed(int tokens) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('textTokens')
        .add({
      'tokens': tokens,
      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .update({'textTokens': FieldValue.increment(tokens)});
  }

  Future<void> _postAudioTokensUsed(int tokens) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('audioTokens')
        .add({
      'tokens': tokens,
      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .update({'audioTokens': FieldValue.increment(tokens)});
  }

  Future<void> _generateAudio(String inputText) async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      loadingAudio = true;
    });
    File speechFile = await OI.OpenAI.instance.audio
        .createSpeech(
      model: "tts-1",
      input: inputText,
      voice: "nova",
      responseFormat: OI.OpenAIAudioSpeechResponseFormat.mp3,
      outputDirectory: Directory(directory.path),
    )
        .then((_) {
      setState(() {
        loadingAudio = false;
        _showControls = true;
        audioPath = _.path;
      });
      return _;
    });

    _playPause();
    _postAudioTokensUsed(latestTokenCount!);
    print(speechFile.path);
  }

  Future<void> _handleInitialMessage(String character) async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      chats.add(
        Messages(role: Role.system, content: character),
      );
    });

    final request = ChatCompleteText(
      messages: [Messages(role: Role.system, content: character)],
      maxToken: 700,
      //model: GptTurboChatModel(),
      model: Gpt4ChatModel(),
    );

    final response = await _openAI.onChatCompletion(request: request);
    final tokenCount = response!.usage!.totalTokens;
    _postTextTokensUsed(tokenCount!.toInt());
    setState(() {
      latestTokenCount = tokenCount.toInt();
    });
    print('Token count: $tokenCount');

    ChatMessage message = ChatMessage(
      text: response.choices.first.message!.content.trim().replaceAll('"', ''),
      isSentByMe: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      chats.add(
        Messages(
          role: Role.assistant,
          content: response.choices.first.message!.content
              .trim()
              .replaceAll('"', ''),
        ),
      );
    });

    setState(() {
      latestMessage = response.choices.first.message!.content.trim();
      _messages.insert(0, message);
      _isLoading = false;
    });
  }

  Future<void> _handleSubmit(String text) async {
    setState(() {
      _isLoading = true;
      latestMessage = text;
    });
    _textController.clear();
    ChatMessage prompt = ChatMessage(
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, prompt);
      chats.add(Messages(role: Role.user, content: text));
    });
    final request = ChatCompleteText(
      messages: chats,
      maxToken: 900,
      model: GptTurboChatModel(),
    );
    final response = await _openAI.onChatCompletion(request: request);
    final totaltokenCount = response!.usage!.totalTokens;
    _postTextTokensUsed(totaltokenCount!.toInt());
    setState(() {
      latestTokenCount = totaltokenCount.toInt();
    });
    print('Token count: $totaltokenCount');

    ChatMessage message = ChatMessage(
      text: response.choices.first.message!.content.trim(),
      isSentByMe: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      chats.add(
        Messages(
          role: Role.assistant,
          content: response.choices.first.message!.content
              .trim()
              .replaceAll('"', ''),
        ),
      );
      latestMessage = response.choices.first.message!.content.trim();
    });

    setState(() {
      _messages.insert(0, message);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLimits();
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
    if (reachedTextLimit == false) {
      _handleInitialMessage(
        'You are a friendly, creative and imaginative storyteller. You can create a story from scratch, or you can use a story that you have already created. Your stories are children\'s stories, and you can use them to teach children about the world around them. Always stick to your role, make user stick to storys and dont answer anything off topic. Provide stories based on prompts given to you. Start by saying something freindly in not more than 2 lines then ask for idea.',
      );
    }
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      setState(() {
        audioloading = true;
      });
      await audioPlayer.play(UrlSource(audioPath)).then((value) => {
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
    if (currentPosition == totalDuration) {
      setState(() {
        isPlaying = false;
      });
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 87, 126, 97),
      body: reachedTextLimit
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 100,
                    color: Colors.white,
                  ),
                  Text(
                    'Limit reached!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Please contact support to upgrade your plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => Card(
                      elevation: 7,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _messages[i].isSentByMe
                              ? const Color.fromARGB(255, 247, 251, 249)
                              : const Color.fromARGB(255, 154, 255, 155),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _messages[i].isSentByMe
                                  ? const AssetImage('')
                                  : const AssetImage(
                                      'images/imagimate-bg.jpeg')),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: _messages[i].isSentByMe
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                            bottomRight: _messages[i].isSentByMe
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width - 180,
                        child: Column(
                          crossAxisAlignment: _messages[i].isSentByMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: _messages[i].isSentByMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Text(
                                  _messages[i].isSentByMe ? "Me" : "ImagiMate",
                                  style: GoogleFonts.montserrat(
                                    color: _messages[i].isSentByMe
                                        ? const Color.fromARGB(255, 189, 84, 84)
                                        : const Color.fromARGB(255, 48, 65, 33),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                _messages[i].isSentByMe
                                    ? const SizedBox(
                                        height: 0,
                                      )
                                    : reachedAudioLimit
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                'Audio limit reached!',
                                                style:
                                                    GoogleFonts.bubblegumSans(
                                                  color: const Color.fromARGB(
                                                      255, 143, 72, 72),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )
                                        : InkWell(
                                            onTap: () async {
                                              await _generateAudio(
                                                  latestMessage!);
                                            },
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                loadingAudio
                                                    ? const CircularProgressIndicator(
                                                        color: Color.fromARGB(
                                                            255, 151, 48, 48),
                                                      )
                                                    : const Icon(
                                                        Icons.headphones,
                                                        size: 30,
                                                        color: Color.fromARGB(
                                                            255, 151, 48, 48),
                                                      ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Listen',
                                                  style:
                                                      GoogleFonts.bubblegumSans(
                                                    color: const Color.fromARGB(
                                                        255, 143, 72, 72),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: _messages[i].isSentByMe
                                  ? const Color.fromARGB(255, 247, 251, 249)
                                  : const Color.fromARGB(255, 216, 243, 217),
                              child: Text(
                                _messages[i].text,
                                style: GoogleFonts.bubblegumSans(
                                  // color:  const Color.fromARGB(255, 55, 105, 64),
                                  color: _messages[i].isSentByMe
                                      ? const Color.fromARGB(255, 111, 63, 63)
                                      : const Color.fromARGB(255, 42, 78, 48),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 154, 255, 155),
                          image: DecorationImage(
                              image: AssetImage('images/imagimate-bg.jpeg'),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "ImagiMate",
                                  style: GoogleFonts.montserrat(
                                    color:
                                        const Color.fromARGB(255, 48, 65, 33),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Typing...",
                              style: GoogleFonts.bubblegumSans(
                                // color:  const Color.fromARGB(255, 55, 105, 64),
                                color: const Color.fromARGB(255, 55, 105, 64),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Card(
                    elevation: 7,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                              style: GoogleFonts.montserrat(
                                color: const Color.fromARGB(255, 233, 122, 122),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              controller: _textController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Type a message',
                                enabled: !_isLoading,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _enteredMessage = value;
                                });
                              }),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            size: 30,
                          ),
                          onPressed: _enteredMessage.trim().isEmpty
                              ? null
                              : () => _handleSubmit(
                                    _enteredMessage,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  color: const Color.fromARGB(255, 244, 255, 244),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/imagimate-bg.jpeg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (audioPath != '')
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
                                        color: const Color.fromARGB(
                                            255, 55, 105, 64),
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
                        if (audioPath != '')
                          Slider(
                            activeColor: const Color.fromARGB(255, 55, 105, 64),
                            value: currentPosition,
                            max: totalDuration,
                            onChanged: (value) {
                              _seek(value);
                            },
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
