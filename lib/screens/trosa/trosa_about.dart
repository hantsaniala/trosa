import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class TrosaAboutPage extends StatefulWidget {
  TrosaAboutPage({Key key}) : super(key: key);

  @override
  _TrosaAboutPageState createState() => _TrosaAboutPageState();
}

class _TrosaAboutPageState extends State<TrosaAboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mombamomba ny Trosa'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: size.height * .05,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Trosa',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _packageInfo.version + '.' + _packageInfo.buildNumber,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * .02,
            ),
            Text(
                "Application natao handraisana naoty an'ireo trosa tokony haloa sy mila takiana.",
                style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: size.height * .05,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Powered by'),
                  FlutterLogo(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
