// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:users_management/app_component/users_info.dart';
import 'package:users_management/app_component/users_list.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 154, 154),
      // margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // seccren info
            double totalWidth = constraints.maxWidth;
            bool tablet = (totalWidth < 1100) ? true : false;
            double namesWidth = tablet
                ? totalWidth * 0.35
                : totalWidth * 0.25; // 15% for names
            double infoWidth = tablet
                ? totalWidth * 0.65
                : totalWidth * 0.75; // 85% for info

            // mobile format
            if (totalWidth < 500) {
              return UsersList();

              // Tablet format
            } else {
              return
              // SizedBox(width: namesWidth, child: UsersList());
              SizedBox(width: double.infinity, child: TableExample());
            }
            // else {
            // // Desktop format
            //   return Row(
            //     children: [
            //       UsersList(),
            //       UserInfoTable(),
            //   ]);
            //   }
          },
        ),
      ),
    );
  }
}
