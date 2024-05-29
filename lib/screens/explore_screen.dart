import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:google_fonts/google_fonts.dart';
import 'package:imagimate/screens/stories_list_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // final _textController = TextEditingController();
  final List<String> storyList = [
    'Adventure',
    'Fantasy',
    'Animal',
    'Horror',
    'Mystery',
    'Educational',
    'Bedtime',
    'Fairy Tales'
  ];
  final List<Color> colorList = [
    const Color.fromARGB(255, 28, 144, 186),
    const Color.fromARGB(255, 155, 83, 229),
    const Color.fromARGB(255, 46, 204, 113),
    const Color.fromARGB(255, 155, 89, 182),
    const Color.fromARGB(255, 52, 73, 94),
    const Color.fromARGB(255, 255, 185, 0),
    const Color.fromARGB(255, 255, 223, 186),
    const Color.fromARGB(255, 255, 204, 255),
  ];
  // var _enteredMessage = '';

  void _navigateToSpecificStories(String selectedCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoriesListScreen(category: selectedCategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 185, 199),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/imagimate-bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Container(
            //   margin: const EdgeInsets.symmetric(
            //     horizontal: 8,
            //     vertical: 12,
            //   ),
            //   child: Card(
            //     child: Row(
            //       children: [
            //         const SizedBox(
            //           width: 10,
            //         ),
            //         Expanded(
            //           child: TextField(
            //               style: GoogleFonts.montserrat(
            //                 color: const Color.fromARGB(255, 233, 122, 122),
            //                 fontSize: 17,
            //                 fontWeight: FontWeight.w400,
            //               ),
            //               controller: _textController,
            //               decoration: const InputDecoration.collapsed(
            //                 hintText: 'Search for stories...',
            //               ),
            //               onChanged: (value) {
            //                 setState(() {
            //                   _enteredMessage = value;
            //                 });
            //               }),
            //         ),
            //         IconButton(
            //           icon: const Icon(
            //             Icons.search,
            //             size: 30,
            //           ),
            //           onPressed: () {},
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 40),
                  itemCount: storyList.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return GestureDetector(
                      onTap: () => _navigateToSpecificStories(storyList[index]),
                      child: Card(
                        elevation: 9,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: colorList[index],
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            storyList[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
