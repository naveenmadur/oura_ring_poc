import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oura_ring_poc/auth_webview.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oura Ring Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Oura Ring Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _linkSubscription;
  Completer<Uri?>? _redirectCompleter;

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandling();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkHandling() {
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          _redirectCompleter != null &&
          !_redirectCompleter!.isCompleted) {
        _redirectCompleter!.complete(uri);
      }
    }, onError: (err) {
      if (kDebugMode) {
        print('Deep link error: $err');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Press the Home button to start the Oura OAuth flow',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: () => authorizeWithOura().then((client) {
                      if (kDebugMode) {
                        print(client);
                      }
                    }),
                child: const Icon(Icons.home))
          ],
        ),
      ),
    );
  }

  Future<Client?> authorizeWithOura() async {
    const String clientId = '';
    const String clientSecret = '';
    const String authorizationEndpoint =
        'https://cloud.ouraring.com/oauth/authorize';
    const String tokenEndpoint = 'https://api.ouraring.com/oauth/token';
    const String redirectUri = 'ouraring://callback';

    final authorizationEndpointUri = Uri.parse(authorizationEndpoint);
    final tokenEndpointUri = Uri.parse(tokenEndpoint);
    final redirectUriUri = Uri.parse(redirectUri);

    try {
      final grant = AuthorizationCodeGrant(
        clientId,
        authorizationEndpointUri,
        tokenEndpointUri,
        secret: clientSecret,
      );

      final Uri authorizationUrl = grant.getAuthorizationUrl(
        redirectUriUri,

        // Add as required
        // scopes: ['daily', 'personal', 'heartrate'],
      );
      if (kDebugMode) log('Authorization URL: $authorizationUrl');

      final completer = Completer<String>();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthWebView(
            authUrl: authorizationUrl.toString(),
            onCodeReceived: (code) {
              completer.complete(code);
            },
          ),
        ),
      );

      final code = await completer.future;
      final client = await grant.handleAuthorizationCode(code);
      if (kDebugMode) log('Access Token: ${client.credentials.accessToken}');
      return client;
    } catch (e, stackTrace) {
      if (kDebugMode) log('OAuth Error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
