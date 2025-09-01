import 'package:flutter/material.dart';
import 'package:users_management/hive_service.dart';
import 'package:users_management/home.dart';
import 'package:users_management/user_info_table.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();

  runApp(
    MaterialApp(
      initialRoute: 'home',
      routes: {
        'home': (context) => Home(),
        'user_info_table': (context) => UserInfoTable(),
      },
    ),
  );
}
