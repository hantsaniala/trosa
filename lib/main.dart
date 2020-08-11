import 'package:flutter/material.dart';
import 'package:Trosa/const.dart';
import 'package:Trosa/notifier/trosa_notifier.dart';
import 'package:Trosa/screens/trosa/trosa_screen.dart';
import 'package:provider/provider.dart';

// BUG : Display lag on GT-i9500
void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TrosaNotifier(),
        )
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trosa',
      theme: ThemeData(
        primarySwatch: KPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: TrosaPage(),
    );
  }
}
