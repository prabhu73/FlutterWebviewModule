import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterInappWebview extends StatefulWidget {
  FlutterInappWebview({Key key}) : super(key: key);

  @override
  _FlutterInappWebviewState createState() => _FlutterInappWebviewState();
}

class _FlutterInappWebviewState extends State<FlutterInappWebview> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController webViewController;
  /*InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));*/

  PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            body: _buildWebView(),
          ),
        ),
        onWillPop: _onBack);
  }

  _buildWebView() {
    return Column(
      children: [
        Expanded(
          child: InAppWebView(
            pullToRefreshController: pullToRefreshController,
            key: webViewKey,
            initialUrlRequest: URLRequest(url: Uri.parse("https://www.acko.com")),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: _buildInAppWebViewOptions(),
                android: _buildAndroidInAppWebViewOptions()),
            onDownloadStart: _onDownloadStart,
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
            onCreateWindow: _onCreateWindow,
            onWebViewCreated: _onWebviewCreated,
            androidOnRenderProcessGone: (cont, detail) {
              StackTrace trace =
              StackTrace.fromString(detail?.toJson()?.toString());
            },
            onLoadStart: _onLoadStart,
            onLoadStop: _onLoadStop,
            onLoadError: _onLoadError,
            onConsoleMessage: _onConsoleMessage,
            onCloseWindow: _onCloseWindow,
            onWindowFocus: _onWindowFocus,
            onProgressChanged: _onProgressChange,
          ),
        ),
      ],
    );
  }

  void _onProgressChange(InAppWebViewController controller, int progress) {
    debugPrint("webview progress " + progress.toString());
  }

  void _onWindowFocus(InAppWebViewController controller) {
    debugPrint("=======> _onWindowFocus");
    // controller.android.clearHistory();
    // controller.loadUrl(url: widget.loadingUrl);
  }

  void _onCloseWindow(InAppWebViewController controller) {
    controller
        .getUrl()
        .then((value) => debugPrint("=======> _onCloseWindow :: $value"));
    Navigator.pop(context, "refresh_web_window");
  }

  void _onConsoleMessage(
      InAppWebViewController controller, ConsoleMessage message) {
    debugPrint("=======> console message ${message.message}");
  }

  void _onLoadError(
      InAppWebViewController controller, Uri url, int code, String message) {
    debugPrint("=======> _onLoadError $url error $message code $code");
  }

  void _onLoadStop(InAppWebViewController controller, Uri url) {
    debugPrint("=======> _onLoadStop");
  }

  void _onLoadStart(InAppWebViewController controller, Uri url) {
    debugPrint("=======> _onLoadStart");
  }

  void _onWebviewCreated(InAppWebViewController controller) {
    webViewController = controller;
    controller.addJavaScriptHandler(
        handlerName: "WebViewConnect",
        callback: (args) async {
          debugPrint("method callback ");
        });
  }

  Future<bool> _onCreateWindow(
      InAppWebViewController controller, CreateWindowAction request) {
    debugPrint("=======> onCreateWindow:: " +
        request.request.url.toString() +
        "\n${request.toString()}\n${request.toJson()}\n${request.toMap().toString()}");
    startWebView(request.request.url.toString(), request.windowId);
    return Future.value(true);
  }

  Future<void> startWebView(String url, int webviewId) async {
    /*var result = await Navigator.pushNamed(context, Routes.WEB_PAGE,
        arguments: {'url': url, "window_id": webviewId});
    if (result == "refresh_web_window") {
      *//*BlocProvider.of<WebViewBloc>(context)
          .add(GetCookiesEvent(url: widget.loadingUrl));*//*
    }*/
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller, NavigationAction action) async {
    var uri = action.request.url;

    if (![
      "http",
      "https",
      "file",
      "chrome",
      "data",
      "javascript",
      "about"
    ].contains(uri.scheme)) {
      if (await canLaunch(url)) {
    // Launch the App
    await launch(
    url,
    );
    // and cancel the request
    return NavigationActionPolicy.CANCEL;
    }
  }
    return NavigationActionPolicy.ALLOW;
  }

  void _onDownloadStart(InAppWebViewController controller, Uri url) {
    debugPrint("=======> onDownloadStart:: " + url.toString());
    Navigator.pop(context);
  }

  AndroidInAppWebViewOptions _buildAndroidInAppWebViewOptions() {
    return AndroidInAppWebViewOptions(
      useOnRenderProcessGone: true,
      supportMultipleWindows: true,
      allowFileAccess: true,
      useHybridComposition: true,
    );
  }

  InAppWebViewOptions _buildInAppWebViewOptions() {
    return InAppWebViewOptions(
        cacheEnabled: false,
        javaScriptEnabled: true,
        useOnDownloadStart: true,
        javaScriptCanOpenWindowsAutomatically: true,
        useShouldOverrideUrlLoading: true);
  }

  /*@override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        body: SafeArea(
            child: Column(children: <Widget>[
              TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search)
                ),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var url = Uri.parse(value);
                  if (url.scheme.isEmpty) {
                    url = Uri.parse("https://www.ackodev.com" + value);
                  }
                  webViewController?.loadUrl(
                      urlRequest: URLRequest(url: url));
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      // contextMenu: contextMenu,
                      initialUrlRequest:
                      URLRequest(url: Uri.parse("https://www.ackodev.com")),
                      // initialFile: "assets/index.html",
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      androidOnPermissionRequest: (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunch(url)) {
                            // Launch the App
                            await launch(
                              url,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController.endRefreshing();
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = this.url;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                    ),
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ]))), onWillPop: _onBack);
  }*/

  Future<bool> _onBack() async {
    var value =
        await webViewController.canGoBack(); // check webview can go back
    if (value) {
      webViewController.goBack(); // perform webview back operation
      return false;
    } else {
      Navigator.of(context).pop();
      return true;
    }
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
