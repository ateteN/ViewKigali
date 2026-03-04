import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'blocs/auth/auth_bloc.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/main_screen.dart';

class ViewKigaliApp extends StatelessWidget {
  const ViewKigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ViewKigali',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('ViewKigali Initializing...'),
        ),
      ),
    );
  }
}
