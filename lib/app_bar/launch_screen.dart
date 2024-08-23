import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PlatformScreen extends StatefulWidget {
  final String url;
  const PlatformScreen({super.key, required this.url});

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection')),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.url),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;

            _webViewController.addJavaScriptHandler(
              handlerName: 'clickHandler',
              callback: (args) {
                print("Element interaction details: ${args[0]}");
              },
            );

            _webViewController.evaluateJavascript(source: """
              // Function to capture element details
              function getElementDetails(event) {
                var elementDetails = {
                  'tag': event.target.tagName,
                  'text': event.target.innerText,
                  'value': event.target.value || '', // capture text field value
                  'attributes': {}
                };
                for (var i = 0; i < event.target.attributes.length; i++) {
                  var attrib = event.target.attributes[i];
                  elementDetails.attributes[attrib.name] = attrib.value;
                }
                return elementDetails;
              }

              // Listen for click events
              document.addEventListener('click', function(event) {
                var details = getElementDetails(event);
                window.flutter_inappwebview.callHandler('clickHandler', details);
              });

              // Listen for input events (e.g., text input)
              document.addEventListener('input', function(event) {
                var details = getElementDetails(event);
                window.flutter_inappwebview.callHandler('clickHandler', details);
              });
            """);
          },
        ),
      ),
    );
  }
}
