import 'package:flutter/material.dart';
import 'package:users_management/app_component/user.dart';
import 'package:users_management/app_component/users_table.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<User> usersList = [];
  void refresh() {
    setState(() {});
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      body: UsersTable(usersList: usersList, onRefresh: refresh,),
      // body: Row(children: [Container(color: Colors.amber, width: 200, height: double.infinity,), Container(width: 200,child: UsersList())],),
    );
  }
}