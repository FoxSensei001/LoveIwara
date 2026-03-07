import 'package:flutter/material.dart';

class RestartApp extends StatefulWidget {
  final Widget child;

  const RestartApp({super.key, required this.child});

  static final GlobalKey<_RestartAppState> _globalKey =
      GlobalKey<_RestartAppState>();

  static Widget scope({required Widget child}) {
    return RestartApp(key: _globalKey, child: child);
  }

  static void restartApp() {
    _globalKey.currentState?.restart();
  }

  @override
  State<RestartApp> createState() => _RestartAppState();
}

class _RestartAppState extends State<RestartApp> {
  Key _subtreeKey = UniqueKey();

  void restart() {
    setState(() {
      _subtreeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _subtreeKey,
      child: widget.child,
    );
  }
}
