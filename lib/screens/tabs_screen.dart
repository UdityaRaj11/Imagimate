import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imagimate/providers/app_user.dart';
import 'package:imagimate/providers/stories.dart';
import 'package:imagimate/providers/user_data.dart';
import 'package:imagimate/screens/auth_screen.dart';
import 'package:imagimate/screens/chat_screen.dart';
import 'package:imagimate/screens/explore_screen.dart';
import 'package:imagimate/screens/profile_screen.dart';
import 'package:imagimate/screens/saved_screen.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';

  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  String? userImageUrl;
  bool userComplete = true;

  late PageController _pageController;
  List<Widget> _pages = [];

  var _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<UserData>(context).fetchAndSetUser();
      Provider.of<Stories>(context).fetchAndSetStories();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const ChatScreen(),
      const ExploreScreen(),
      const SavedScreen(),
      const ProfileScreen(),
    ];

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserData userProvider = Provider.of<UserData>(context);
    AppUser? user = userProvider.user;
    String imageUrl = '';
    if (user != null) {
      setState(() {
        imageUrl = user.imageUrl.toString();
      });
    }
    return Scaffold(
      appBar: AppBar(
          titleTextStyle: const TextStyle(
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 100, 144, 112),
          title: Text(
            "ImagiMate",
            style: GoogleFonts.schoolbell(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            DropdownButton(
              underline: Container(),
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'logout',
                  child: SizedBox(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  FirebaseAuth.instance.signOut().then(
                        (value) => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const AuthScreen()),
                            (route) => false),
                      );
                }
              },
            ),
          ]),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: const Color.fromARGB(255, 100, 144, 112),
        unselectedItemColor: const Color.fromARGB(255, 181, 217, 205),
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.bookmark_outlined),
            activeIcon: const Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: imageUrl != ""
                ? CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(imageUrl),
                  )
                : const CircularProgressIndicator(),
            activeIcon: const Icon(
              Icons.person,
              size: 35,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
