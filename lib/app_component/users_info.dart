// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:users_management/app_component/user.dart';
import 'package:users_management/app_theme.dart';
import 'package:users_management/hive_service.dart';

class TableExample extends StatefulWidget {
  const TableExample({super.key});

  @override
  State<TableExample> createState() => _TableExampleState();
}

class _TableExampleState extends State<TableExample> {
  late List<User> usersList = [
    User(name: 'name', userId: 'userId', phone: 'phone'),
  ];

  @override
  void initState() {
    super.initState();

    usersList = HiveService.getUsersList();
  }

  // scroll controller for the table
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  TextEditingController notesController = TextEditingController();

  List<DataRow> crateRows() {
    List<DataRow> rows = [];

    for (int i = 0; i < usersList.length; i++) {
      rows.add(
        DataRow(
          cells: <DataCell>[
            DataCell(Text(usersList[i].userId, style: AppTheme.tableCellText)),
            DataCell(
              Text(usersList[i].name, style: AppTheme.tableCellText),
              onTap: () {
                usersList[i].showActivationsDialog(context);
              },
            ),
            DataCell(Text(usersList[i].phone, style: AppTheme.tableCellText)),

            DataCell(
              usersList[i].activations.isNotEmpty
                  ? Text(
                      usersList[i].activations.last.type,
                      style: AppTheme.tableCellText,
                    )
                  : Text("No Supscription yet", style: AppTheme.tableCellText),
            ),
            DataCell(
              usersList[i].activations.isNotEmpty
                  ? Text(
                      usersList[i].activations.last.toString(),
                      style: AppTheme.tableCellText,
                    )
                  : Text("No Supscription yet", style: AppTheme.tableCellText),
            ),
            DataCell(Text(usersList[i].notes, style: AppTheme.tableCellText)),

            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      usersList[i].showAddActivationDialog(context);
                    },
                    icon: Icon(
                      Icons.receipt_rounded,
                      color: AppTheme.iconsColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: AppTheme.iconsColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  Future<void> showAddUserDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New User'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name TextField==========
                      TextField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Phone TextField==========
                      TextField(
                        controller: _phone,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Notes TextField
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add User'),
                  onPressed: () {
                    // Validate required fields
                    if (_name.text.isNotEmpty && _phone.text.isNotEmpty) {
                      usersList.add(
                        User(
                          name: _name.text,
                          userId: (usersList.length + 1).toString(),
                          phone: _phone.text,
                          notes: notesController.text,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'User ${_name.text} Added Successfully',
                          ),
                        ),
                      );
                      update();
                      Navigator.of(
                        context,
                      ).pop(true); // Return true to indicate a user was added
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a name')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // add new user function
  void update() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: DataTable(
        columns: <DataColumn>[
          DataColumn(label: Text('Id', style: AppTheme.tableColumnText)),
          DataColumn(
            label: Expanded(
              child: Text('Name', style: AppTheme.tableColumnText),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text('Phone', style: AppTheme.tableColumnText),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text('Subscription Type', style: AppTheme.tableColumnText),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text('Days Left', style: AppTheme.tableColumnText),
            ),
          ),
          DataColumn(
            columnWidth: FlexColumnWidth(0.7),
            label: Expanded(
              child: Text('Nots', style: AppTheme.tableColumnText),
            ),
          ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showAddUserDialog(context);
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.iconsColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HiveService.storeUsersList(usersList);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Users data saved locally')),
                      );
                    },
                    icon: Icon(
                      Icons.storage_rounded,
                      color: AppTheme.iconsColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        rows: crateRows(),
      ),
    );
  }
}
