import 'package:flutter/material.dart';
import 'package:flutter_application_1/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: const Index(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        // bottomNavigationBar: BottomNavigationBar(items: [
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        // ]),
      ),
    );
  }
}
