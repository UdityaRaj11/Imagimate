import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:imagimate/providers/user_data.dart';
import 'firebase_options.dart';
import 'package:imagimate/screens/auth_screen.dart';
import 'package:imagimate/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imagimate/screens/tabs_screen.dart';
import 'package:imagimate/providers/stories.dart';
import 'package:dart_openai/dart_openai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => dotenv.load(fileName: "assets/.env"));
  OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Stories(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserData(),
        ),
      ],
      child: MaterialApp(
        title: 'ImagiMate',
        theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              final user = FirebaseAuth.instance.currentUser;
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              if (userSnapshot.hasData || user != null) {
                return const TabsScreen();
              } else {
                return const AuthScreen();
              }
            }),
        routes: {
          TabsScreen.routeName: (ctx) => const TabsScreen(),
        },
      ),
    );
  }
}
