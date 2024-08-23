import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_bar/app_bar.dart';
import 'app_bar/drawer.dart';
import 'app_bar/launch_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWidget.appOpen(context, 'https://in.pinterest.com')
    );
  }
}

class AppWidget {
  static Scaffold appOpen(BuildContext context, url) {
    late InAppWebViewController _webViewController;
    return Scaffold(
      appBar: AppBarWidget.appbar(),
      drawer: const DrawerW(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(url),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
        ),
      ),
    );
  }
}