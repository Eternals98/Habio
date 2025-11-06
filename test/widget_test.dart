// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:per_habit/firebase_options.dart';
import 'package:per_habit/main.dart';

FirebaseOptions _resolveFirebaseOptions() {
  try {
    return DefaultFirebaseOptions.currentPlatform;
  } on UnsupportedError {
    return DefaultFirebaseOptions.android;
  }
}

CoreFirebaseOptions _asCoreOptions(FirebaseOptions options) {
  return CoreFirebaseOptions(
    apiKey: options.apiKey,
    appId: options.appId,
    messagingSenderId: options.messagingSenderId,
    projectId: options.projectId,
    authDomain: options.authDomain,
    databaseURL: options.databaseURL,
    storageBucket: options.storageBucket,
    measurementId: options.measurementId,
    trackingId: options.trackingId,
    deepLinkURLScheme: options.deepLinkURLScheme,
    androidClientId: options.androidClientId,
    iosClientId: options.iosClientId,
    iosBundleId: options.iosBundleId,
    appGroupId: options.appGroupId,
  );
}

class _ProductionFirebaseCoreHostApi implements TestFirebaseCoreHostApi {
  _ProductionFirebaseCoreHostApi(this._options);

  final FirebaseOptions _options;

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: initializeAppRequest,
      isAutomaticDataCollectionEnabled: true,
      pluginConstants: <String?, Object?>{},
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return <CoreInitializeResponse>[
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: _asCoreOptions(_options),
        isAutomaticDataCollectionEnabled: true,
        pluginConstants: <String?, Object?>{},
      ),
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return _asCoreOptions(_options);
  }
}

Future<void> _ensureFirebaseInitialized() async {
  final firebaseOptions = _resolveFirebaseOptions();

  TestFirebaseCoreHostApi.setUp(_ProductionFirebaseCoreHostApi(firebaseOptions));

  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      rethrow;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _ensureFirebaseInitialized();
  });

  testWidgets('renders the Habio app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Habio');
  });
}
