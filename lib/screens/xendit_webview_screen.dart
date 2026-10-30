import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';


class XenditWebViewScreen extends StatefulWidget {
  final String url;
  const XenditWebViewScreen({super.key, required this.url});


  @override
  State<XenditWebViewScreen> createState() => _XenditWebViewScreenState();
}


class _XenditWebViewScreenState extends State<XenditWebViewScreen> {
  WebViewController? _controller;
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    // The in-app WebView only exists on Android/iOS, not on web.
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
        ))
        ..loadRequest(Uri.parse(widget.url));
    }
  }


  Future<void> _openInBrowser() async {
    await launchUrl(Uri.parse(widget.url),
        mode: LaunchMode.externalApplication);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.navy,
        foregroundColor: Colors.white,
        title: const Text('Secure Payment'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: kIsWeb ? _webBody() : _mobileBody(),
    );
  }


  Widget _mobileBody() => Stack(children: [
        WebViewWidget(controller: _controller!),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ]);


  Widget _webBody() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.payments_outlined,
                size: 70, color: AppConfig.navy),
            const SizedBox(height: 12),
            const Text('Complete your payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '1. Tap the button to open the Xendit page in a new tab.\n'
                '2. Choose GCash or Maya and press the test simulation button.\n'
                '3. Come back here and tap Done (top right).',
                textAlign: TextAlign.left),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: AppConfig.navy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open payment page'),
            ),
          ]),
        ),
      );
}