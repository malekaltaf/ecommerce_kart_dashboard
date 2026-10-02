import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/login_viewmodel.dart';
import 'views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provide LoginViewModel at the root so it survives navigation events
      create: (_) => LoginViewModel(),
      child: MaterialApp(
        title: 'Ecommerce Kart Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginView(),
      ),
    );
  }
}
