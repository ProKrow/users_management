// // ignore_for_file: avoid_print
// import 'package:flutter/material.dart';
// import 'package:users_management/app_component/user.dart';
// import 'package:users_management/app_theme.dart';
// import 'package:users_management/hive_service.dart';

// class TableExample extends StatefulWidget {
//   const TableExample({super.key});

//   @override
//   State<TableExample> createState() => _TableExampleState();
// }

// class _TableExampleState extends State<TableExample> {
//   final TextEditingController _userName = TextEditingController();
//   final TextEditingController _phone = TextEditingController();
//   final TextEditingController notesController = TextEditingController();

//   late List<User> usersList = [
//     User(userName: 'userName', userId: 1, phone: 'phone'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     usersList = HiveService.getUsersList();
//   }

//   // scroll controller for the table
//   final ScrollController _scrollController = ScrollController();

//   Future<void> showAddUserDialog(BuildContext context) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Add New User'),
//               content: SingleChildScrollView(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // userName TextField==========
//                       TextField(
//                         controller: _userName,
//                         decoration: InputDecoration(
//                           labelText: 'userName',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Phone TextField==========
//                       TextField(
//                         controller: _phone,
//                         decoration: InputDecoration(
//                           labelText: 'Phone',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Payed Amount TextField==========
//                       TextField(
//                         controller: notesController,
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           labelText: 'Payed',
//                           border: OutlineInputBorder(),
//                           alignLabelWithHint: true,
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Notes TextField
//                       TextField(
//                         controller: notesController,
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           labelText: 'Notes',
//                           border: OutlineInputBorder(),
//                           alignLabelWithHint: true,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 ElevatedButton(
//                   child: Text('Add User'),
//                   onPressed: () {
//                     // Validate required fields
//                     if (_userName.text.isNotEmpty) {
//                       if (usersList.any(
//                         (user) => user.userName == _userName.text,
//                       )) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Username already exists')),
//                         );
//                         return;
//                       }
//                       usersList.add(
//                         User(
//                           userName: _userName.text,
//                           userId: (usersList.length + 1),
//                           phone: _phone.text,
//                           notes: notesController.text,
//                         ),
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             'User ${_userName.text} Added Successfully',
//                           ),
//                         ),
//                       );
//                       update();
//                       Navigator.of(
//                         context,
//                       ).pop(true); // Return true to indicate a user was added

//                       // clear the controllers
//                       _userName.clear();
//                       _phone.clear();
//                       notesController.clear();
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Please enter a userName')),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // add new user function
//   void update() async {
//     setState(() {});
//   }

//   List<DataRow> crateRows() {
//     List<DataRow> rows = [];

//     for (int i = 0; i < usersList.length; i++) {
//       rows.add(
//         DataRow(
//           cells: <DataCell>[
//             DataCell(
//               Text(
//                 usersList[i].userId.toString(),
//                 style: AppTheme.tableCellText,
//               ),
//             ),
//             DataCell(
//               Text(usersList[i].userName, style: AppTheme.tableCellText),
//               onTap: () {
//                 usersList[i].showActivationsDialog(context);
//               },
//             ),

//             // DataCell(Text(usersList[i].phone, style: AppTheme.tableCellText)),
//             DataCell(
//               Center(
//                 child: usersList[i].activations.isNotEmpty
//                     ? Text(
//                         usersList[i].activations.last.type,
//                         style: AppTheme.tableCellText,
//                       )
//                     : Text(
//                         "No Supscription yet",
//                         style: AppTheme.tableCellText,
//                       ),
//               ),
//             ),
//             // Days Left
//             DataCell(
//               Center(
//                 child: usersList[i].activations.isNotEmpty
//                     ? Text(
//                         usersList[i].daysLeft.toString(),
//                         style: AppTheme.tableCellText,
//                       )
//                     : Text(
//                         "No Supscription yet",
//                         style: AppTheme.tableCellText,
//                       ),
//               ),
//             ),

//             // Payed Amount
//             DataCell(
//               Center(
//                 child: usersList[i].activations.isNotEmpty
//                     ? Text(
//                         usersList[i].activations.last.debtAmount.toString(),
//                         style: AppTheme.tableCellText,
//                       )
//                     : Text(
//                         "No Supscription yet",
//                         style: AppTheme.tableCellText,
//                       ),
//               ),
//             ),
//             // activation date
//             DataCell(
//               Center(
//                 child: usersList[i].activations.isNotEmpty
//                     ? Text(
//                         usersList[i].activations.last.activationDate.toString(),
//                         style: AppTheme.tableCellText,
//                       )
//                     : Text(
//                         "No Supscription yet",
//                         style: AppTheme.tableCellText,
//                       ),
//               ),
//             ),
//             // expiry date
//             DataCell(
//               Center(
//                 child: usersList[i].activations.isNotEmpty
//                     ? Text(
//                         usersList[i].activations.last.expiryDate.toString(),
//                         style: AppTheme.tableCellText,
//                       )
//                     : Text(
//                         "No Supscription yet",
//                         style: AppTheme.tableCellText,
//                       ),
//               ),
//             ),
//             DataCell(Text(usersList[i].notes, style: AppTheme.tableCellText)),

//             DataCell(
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     onPressed: () async {
//                       await usersList[i].showAddActivationDialog(context);
//                       setState(() {}); // Ensure UI updates after activation is added
//                     },
//                     icon: Icon(
//                       Icons.receipt_rounded,
//                       color: AppTheme.iconsColor,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.edit, color: AppTheme.iconsColor),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return rows;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: DataTable(
//         columns: <DataColumn>[
//           DataColumn(label: Text('Id', style: AppTheme.tableColumnText)),
//           DataColumn(
//             label: Expanded(
//               child: Text('userName', style: AppTheme.tableColumnText),
//             ),
//           ),
//           // phone column (commented out)
//           // DataColumn(
//           //   label: Expanded(
//           //     child: Text('Phone', style: AppTheme.tableColumnText),
//           //   ),
//           // ),
//           DataColumn(
//             label: Expanded(
//               child: Text('Subscription Type', style: AppTheme.tableColumnText),
//             ),
//           ),
//           DataColumn(
//             label: Expanded(
//               child: Text('Days Left', style: AppTheme.tableColumnText),
//             ),
//           ),
//           // Payed Amount column
//           DataColumn(
//             label: Expanded(
//               child: Text('Payed', style: AppTheme.tableColumnText),
//             ),
//           ),
//           // activation date column
//           DataColumn(
//             label: Expanded(
//               child: Text('Activ date', style: AppTheme.tableColumnText),
//             ),
//           ),
//           // expiry date column
//           DataColumn(
//             label: Expanded(
//               child: Text('Expiry date', style: AppTheme.tableColumnText),
//             ),
//           ),
//           DataColumn(
//             columnWidth: FlexColumnWidth(0.7),
//             label: Expanded(
//               child: Text('Nots', style: AppTheme.tableColumnText),
//             ),
//           ),
//           DataColumn(
//             label: Align(
//               alignment: Alignment.centerRight,
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () async {
//                       final User? user = await User.showAddUserDialog(
//                         context,
//                         usersList.length + 1,
//                       );
//                       if (user != null) {
//                         setState(() {
//                           usersList.add(user);
//                         });
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               'User ${user.userName} Added Successfully',
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     icon: Icon(
//                       Icons.add_circle_outline,
//                       color: AppTheme.iconsColor,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       HiveService.storeUsersList(usersList);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Users data saved locally')),
//                       );
//                     },
//                     icon: Icon(
//                       Icons.storage_rounded,
//                       color: AppTheme.iconsColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//         rows: crateRows(),
//       ),
//     );
//   }
// }
