import 'package:flutter/material.dart';
import 'package:users_management/app_component/user.dart';

class UsersList extends StatelessWidget {
  UsersList({super.key});

  final List<User> usersList = [
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: usersList.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Text(
              usersList[index].userId,
              style: TextStyle(
                backgroundColor: const Color.fromARGB(255, 194, 193, 193),
                color: const Color.fromARGB(255, 4, 4, 4),
                fontWeight: FontWeight.w500,
              ),
            ),
            title: Text(usersList[index].name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
            // subtitle: Text('User ID: ${index + 1}', style: TextStyle(fontSize: 14, color: Colors.grey),),
            onTap: (){},
          ),
        );
      },
    );
  }
}
