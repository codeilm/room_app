import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_app/data/moor_database.dart';
import 'package:room_app/ui/home_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final AppDatabase db = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => db.taskDao,
        ),
        Provider(
          create: (context) => db.tagDao,
        ),
      ],
      child: MaterialApp(
        title: 'room',
        home: HomeScreen(),
      ),
    );
  }
}
