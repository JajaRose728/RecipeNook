import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'supabase_keys.dart'; // contains SUPABASE_URL and SUPABASE_ANON_KEY

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gfkxgffgeezpqvweroxt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdma3hnZmZnZWV6cHF2d2Vyb3h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNjIwOTksImV4cCI6MjA3ODYzODA5OX0.vbh4W8d_BBYQbEF13hWpElkyUEO8j9qSX2XC1560_gw',
  );

  runApp(const RecipeNookApp());
}

class RecipeNookApp extends StatelessWidget {
  const RecipeNookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeNook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: LoginPage(),
    );
  }
}
