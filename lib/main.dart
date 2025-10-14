import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/firebase_options.dart';
import 'package:habitbegone_admin/test2/provider/theme_provider.dart';
import 'package:habitbegone_admin/test2/provider/user_provider.dart';
import 'package:habitbegone_admin/test2/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUserData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Admin App',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const LoginScreen(),
    );
  }
}








// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:habitbegone_admin/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   print('✅ Firebase initialized successfully!');
  // } catch (e) {
  //   print('❌ Firebase initialization failed: $e');
  // }
//   // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(body: Center(child: Text('Firebase CLI setup done! 🚀'))),
//     );
//   }
// }
