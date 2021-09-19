import 'package:flutter/material.dart';
import 'package:Trosa/const.dart';
import 'package:Trosa/notifier/trosa_notifier.dart';
import 'package:Trosa/screens/trosa/trosa_screen.dart';
import 'package:provider/provider.dart';

// BUG : Display lag on GT-i9500
// BUG : App stuck on fullscreen

// TODO : Update splash screen

// FEATURE : Notification reminder for due date
// FEATURE : Widget for descktop (resume and add)

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TrosaNotifier(),
        )
      ],
      child: Trosa(),
    ),
  );
}

class Trosa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trosa',
      theme: ThemeData(
        primarySwatch: KPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: TrosaPage(),
    );
  }
}
