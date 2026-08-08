import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trosa/const.dart';
import 'package:trosa/notifier/trosa_notifier.dart';
import 'package:trosa/screens/trosa/trosa_screen.dart';

void main() {
  runApp(const TrosaApp());
}

class TrosaApp extends StatelessWidget {
  const TrosaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TrosaNotifier(),
        )
      ],
      child: const Trosa(),
    );
  }
}

class Trosa extends StatelessWidget {
  const Trosa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trosa',
      theme: ThemeData(
        primarySwatch: KPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: const TrosaPage(),
    );
  }
}
