import 'package:flutter/material.dart';
import 'package:imagimate/widgets/readable_list.dart';
import 'package:imagimate/widgets/video_list.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:imagimate/providers/stories.dart';
import 'package:imagimate/providers/story.dart';

class StoriesListScreen extends StatefulWidget {
  final String category;
  const StoriesListScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final YoutubeExplode youtubeExplode = YoutubeExplode();
  late PageController pageController;
  List<Widget> listType = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedPageIndex);
  }

  int selectedPageIndex = 0;

  void selectList(int index) {
    setState(() {
      selectedPageIndex = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Stories storiesProvider = Provider.of<Stories>(context);
    List<Story> stories =
        storiesProvider.getStoriesForCategory(widget.category);
    String searchQuery = "${widget.category} stories for kids";
    Future<VideoSearchList> videos = youtubeExplode.search.search(searchQuery);
    setState(() {
      listType = [
        ReadableList(stories: stories),
        VideoList(videos: videos),
      ];
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 87, 126, 97),
        title: Text(
          'Stories - ${widget.category}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 65, 95, 73),
      body: PageView(
        controller: pageController,
        onPageChanged: selectList,
        children: listType,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectList,
        backgroundColor: const Color.fromARGB(255, 87, 126, 97),
        unselectedItemColor: const Color.fromARGB(255, 181, 217, 205),
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Readables',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}
