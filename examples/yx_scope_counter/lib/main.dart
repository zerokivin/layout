import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import 'counter/ui/component/counter_layout.dart';
import 'counter/ui/component/disable_counter_layout.dart';
import 'scope/app_scope.dart';
import 'scope/app_scope_holder.dart';

Future<void> main() async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();
  bindings.deferFirstFrame();

  final scopeHolder = AppScopeHolder();
  await scopeHolder.create();

  bindings.allowFirstFrame();

  runApp(
    ScopeProvider<AppScope>(
      holder: scopeHolder,
      child: const MyApp(),
    ),
  );
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
    return ScopeBuilder<AppScope>.withPlaceholder(
      builder: (_, scope) {
        final factory = scope.counterLayoutControllerFactory;

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              Scaffold(
                body: Center(
                  child: CounterLayout(factory),
                ),
              ),
              Scaffold(
                body: Center(
                  child: DisableCounterLayout(factory),
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
      },
    );
  }
}
