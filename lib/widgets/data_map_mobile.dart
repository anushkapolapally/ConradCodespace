import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DataMapWidget extends StatefulWidget {
  const DataMapWidget({super.key});

  @override
  State<DataMapWidget> createState() => _DataMapWidgetState();
}

class _DataMapWidgetState extends State<DataMapWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadFlutterAsset('assets/map.html');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(controller: _controller),
    );
  }
}