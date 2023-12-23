import 'package:flutter/material.dart';
import 'package:singstar/routes/game_route.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Karaokay',
      home: Scaffold(body: GameRoute()),
    );
  }
}
