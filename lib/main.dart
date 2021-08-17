import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_wandroid/screens/home.dart';
import 'package:riverpod_wandroid/screens/home_tab_setting.dart';

void main() {
  runApp(const ProviderScope(observers: [SimpleObserver()], child: MyApp()));
}

class SimpleObserver extends ProviderObserver {
  const SimpleObserver();
  @override
  void didAddProvider(
      ProviderBase provider, Object? value, ProviderContainer container) {
    log('didAddProvider: ${provider.runtimeType}, value:$value');
    super.didAddProvider(provider, value, container);
  }

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    log('didUpdateProvider: ${provider.runtimeType}, newValue: $newValue');
    super.didUpdateProvider(provider, previousValue, newValue, container);
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer containers) {
    log('didDisposeProvider: ${provider.runtimeType}');
    super.didDisposeProvider(provider, containers);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => const Home(),
        '/tab_setting': (_) => const HomeTabSetting(),
      },
      initialRoute: '/',
    );
  }
}
