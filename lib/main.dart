import 'package:allsocialmedia/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_bar/app_bar.dart';
import 'app_bar/drawer.dart';
import 'app_bar/launch_screen.dart';
import 'file_upload/upload_home/upload_files.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // home: MyHomePage(),
      home: FileUploadScreen(),
      // home: FingerPrintAuth(),
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