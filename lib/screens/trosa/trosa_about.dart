import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TrosaAboutPage extends StatefulWidget {
  const TrosaAboutPage({super.key});

  @override
  State<TrosaAboutPage> createState() => _TrosaAboutPageState();
}

class _TrosaAboutPageState extends State<TrosaAboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final info = _packageInfo;
    final version = info != null
        ? '${info.version}.${info.buildNumber}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mombamomba ny Trosa'),
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
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    version,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * .02,
            ),
            Text(
              'Application natao handraisana naoty ireo trosa tokony haloa sy mila takiana.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              height: size.height * .05,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
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
