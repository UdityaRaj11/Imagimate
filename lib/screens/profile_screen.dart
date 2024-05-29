import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imagimate/providers/app_user.dart';
import 'package:imagimate/providers/user_data.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userProvider = Provider.of<UserData>(context);
    AppUser? user = userProvider.user;
    String imageUrl = '';
    String userName = 'No User Name';
    String email = 'No Email';
    if (user != null) {
      setState(() {
        imageUrl = user.imageUrl.toString();
        userName = user.username.toString();
        email = user.email.toString();
      });
    }
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 185, 199),
      body: Container(
        width: deviceWidth,
        height: deviceHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/imagimate-bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Card(
            elevation: 7,
            child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/bg1.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
                width: deviceWidth * 0.9,
                height: deviceHeight * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Profile',
                          style: GoogleFonts.schoolbell(
                            color: const Color.fromARGB(255, 150, 87, 87),
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Card(
                          shape: ShapeBorder.lerp(
                            const CircleBorder(),
                            const RoundedRectangleBorder(),
                            0,
                          ),
                          elevation: 7,
                          child: imageUrl != ""
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(imageUrl),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                    Card(
                      margin: const EdgeInsets.all(5),
                      color: const Color.fromARGB(255, 255, 224, 222),
                      child: ListTile(
                        title: Text(
                          'User Name',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 113, 146, 143),
                          ),
                        ),
                        subtitle: Text(
                          userName,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 148, 191, 187),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(5),
                      color: const Color.fromARGB(255, 255, 224, 222),
                      child: ListTile(
                        title: Text(
                          'Email',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 113, 146, 143),
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 148, 191, 187),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
