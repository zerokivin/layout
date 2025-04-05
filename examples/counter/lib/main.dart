import 'package:flutter/material.dart';

import 'counter/layout/counter_layout.dart';
import 'counter/layout/disable_counter_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          Scaffold(
            body: Center(
              child: CounterLayout(),
            ),
          ),
          Scaffold(
            body: Center(
              child: DisableCounterLayout(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() => _index = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'CounterLayout',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_disabled),
            label: 'DisableCounterLayout',
          ),
        ],
      ),
    );
  }
}
