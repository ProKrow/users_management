import 'package:flutter/material.dart';

class UserInfoTable extends StatefulWidget {
  const UserInfoTable({super.key});

  @override
  State<UserInfoTable> createState() => _UserInfoTableState();
}

class _UserInfoTableState extends State<UserInfoTable> {
  String selectedSubscriptionType = 'Basic';
  String selectedPaymentMethod = 'Cash';
  DateTime? activationDate;
  DateTime? repaymentDate;
  TextEditingController notesController = TextEditingController();

  List<String> subscriptionTypes = ['Basic', 'Premium', 'Pro', 'Enterprise'];
  List<String> paymentMethods = [
    'Cash',
    'MasterCard',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info Table'),
      ),
      body: Column(
        children: [
          // First Row - Empty text
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter text',
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          // Second Row - Activation Date
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Activation Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          activationDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activationDate != null
                            ? '${activationDate!.day}/${activationDate!.month}/${activationDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          // Third Row - Subscription Type
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Subscription Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedSubscriptionType,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: subscriptionTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
      
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubscriptionType = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
      
          // Fourth Row - Repayment Date
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Repayment Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          repaymentDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        repaymentDate != null
                            ? '${repaymentDate!.day}/${repaymentDate!.month}/${repaymentDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          // Fifth Row - Payment Method
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
      
          // Sixth Row - Notes
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter notes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
