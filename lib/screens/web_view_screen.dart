import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      // If platform is not set, try to set it here as a last resort
      if (WebViewPlatform.instance == null) {
        final platform = Theme.of(context).platform;
        if (platform == TargetPlatform.android) {
          WebViewPlatform.instance = AndroidWebViewPlatform();
        } else if (platform == TargetPlatform.iOS) {
          WebViewPlatform.instance = WebKitWebViewPlatform();
        }
      }

      if (WebViewPlatform.instance == null) {
        setState(() => _hasError = true);
        return;
      }

      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      _controller = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) setState(() => _loadingProgress = progress);
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              if (mounted) setState(() => _loadingProgress = 100);
            },
            onWebResourceError: (WebResourceError error) {},
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      setState(() => _hasError = true);
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.url,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: (_controller != null && _loadingProgress < 100)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  color: AppTheme.accent,
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: _hasError || _controller == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.language_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'In-app reader is not available on this platform.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text('OPEN IN BROWSER'),
                    ),
                  ],
                ),
              ),
            )
          : WebViewWidget(controller: _controller!),
    );
  }
}
