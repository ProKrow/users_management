// ignore_for_file: sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:users_management/app_theme.dart';
import 'package:hive/hive.dart';

// Clean Activations class - contains only activation data and logic

// Clean Activations class - contains only activation data and logic
@HiveType(typeId: 0)
class Activations {
  @HiveField(0)
  final DateTime activationDate;
  @HiveField(1)
  final DateTime expiryDate;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final String paymentMethod;
  @HiveField(4)
  final bool status;
  @HiveField(5)
  final double pricePaid;
  @HiveField(6)
  final bool payed;
  @HiveField(7)
  final String notes;
  @HiveField(8)
  final double fullPrice;
  @HiveField(9)
  final String tower;

  Activations({
    required this.activationDate,
    required this.expiryDate,
    required this.type,
    required this.paymentMethod,
    required this.status,
    this.pricePaid = 0,
    required this.payed,
    this.notes = '',
    this.fullPrice = 0,
    this.tower = 'N',
  });

  // Calculate remaining debt
  double get debtAmount => fullPrice - pricePaid;

  // Check if there's any debt
  bool get hasDebt => debtAmount > 0;

  // Get status color based on payment and expiry
  Color get statusColor {
    if (!payed && hasDebt) return AppTheme.errorColor;
    if (expiryDate.isBefore(DateTime.now())) return AppTheme.textHint;
    if (status) return AppTheme.successColor;
    return AppTheme.secondaryColor;
  }

  // Get status text
  String get statusText {
    if (!payed && hasDebt) return 'Has Debt';
    if (expiryDate.isBefore(DateTime.now())) return 'Expired';
    if (status) return 'Active';
    return 'Inactive';
  }

  // Create a copy of this activation with updated payment info
  Activations copyWithPayment(double additionalPayment) {
    double newPricePaid = pricePaid + additionalPayment;
    return Activations(
      activationDate: activationDate,
      expiryDate: expiryDate,
      type: type,
      tower: tower,
      paymentMethod: paymentMethod,
      status: status,
      pricePaid: newPricePaid,
      payed: newPricePaid >= fullPrice,
      notes: notes,
      fullPrice: fullPrice,
    );
  }

  // Create a copy of this activation with updated values
  Activations copyWith({
    DateTime? activationDate,
    DateTime? expiryDate,
    String? type,
    String? paymentMethod,
    bool? status,
    double? pricePaid,
    bool? payed,
    String? notes,
    double? fullPrice,
  }) {
    return Activations(
      activationDate: activationDate ?? this.activationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      pricePaid: pricePaid ?? this.pricePaid,
      payed: payed ?? this.payed,
      notes: notes ?? this.notes,
      fullPrice: fullPrice ?? this.fullPrice,
    );
  }
}

// Enhanced User class with UI methods and activation management
@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String userName;
  @HiveField(1)
  final int userId;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  String notes;
  @HiveField(4)
  List<Activations> activations = [];
  @HiveField(5)
  String? name;

  // Form controllers for dialogs
  late DateTime activationDatePicker;
  late DateTime repaymentDate;

  // Controllers for user info
  final TextEditingController pricePaidController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String? selectedSubscriptionType = 'A35';
  String? selectedTowerType = 'N';
  String selectedPaymentMethod = 'Cash';

  // Static dropdown options
  static List<String> subscriptionTypesA = ['A35', 'A45', 'A75', 'A150'];
  static List<String> subscriptionTypesB = ['B30', 'B35', 'B45', 'B75'];
  static List<String> paymentMethods = ['Cash', 'MasterCard'];
  static List<String> towers = ['N', 'B', 'M', 'BS', 'NB'];

  User({
    required this.userName,
    required this.userId,
    required this.phone,
    this.notes = "no notes",
    List<Activations>? activations,
  }) : activations = activations ?? [];

  // Add activation to this user
  void addActivation(Activations activation) {
    activations.add(activation);
  }

  // Update activation at a specific index
  void updateActivation(int index, Activations newActivation) {
    if (index >= 0 && index < activations.length) {
      activations[index] = newActivation;
    }
  }

  // Remove activation by index
  void removeActivation(int index) {
    if (index >= 0 && index < activations.length) {
      activations.removeAt(index);
    }
  }

  // Days left for the latest activation
  int get daysLeft {
    if (activations.isEmpty) return 0;
    final latestActivation = activations.last;
    final difference = latestActivation.expiryDate.difference(DateTime.now());
    return difference.inDays;
  }

  // Get total debt for this user
  double get totalDebt {
    return activations
        .where((activation) => activation.hasDebt)
        .fold(0, (sum, activation) => sum + activation.debtAmount);
  }

  // Get active activations count
  int get activeActivationsCount {
    return activations
        .where(
          (activation) =>
              activation.status &&
              activation.expiryDate.isAfter(DateTime.now()),
        )
        .length;
  }

  // Check if user has any debts
  bool get hasDebt => totalDebt > 0;

  // Get activations with debt
  List<Activations> get debtActivations {
    return activations.where((activation) => activation.hasDebt).toList();
  }

  // Helper method to get subscription price
  double _getSubscriptionPrice(String subscriptionType) {
    switch (subscriptionType) {
      case 'A35':
        return 35.0;
      case 'A45':
        return 45.0;
      case 'A75':
        return 75.0;
      case 'A150':
        return 150.0;
      case 'B30':
        return 30.0;
      case 'B35':
        return 35.0;
      case 'B45':
        return 45.0;
      case 'B75':
        return 75.0;
      default:
        return 0.0;
    }
  }

  // Static method to show add user dialog
  static Future<User?> showAddUserDialog(BuildContext context, int id) async {
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    bool includeActivation = false;

    // Variables for activation (if included)
    DateTime activationDatePicker = DateTime.now();
    DateTime repaymentDate = DateTime.now().add(Duration(days: 30));
    final TextEditingController pricePaidController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedSubscriptionType = 'A35';
    String selectedTowerType = 'N';
    String selectedPaymentMethod = 'Cash';

    return showDialog<User?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Add New User', style: AppTheme.titleLarge),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Name TextField
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: userNameController,
                          decoration: AppTheme.inputDecoration('User Name')
                              .copyWith(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Phone TextField
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: phoneController,
                          decoration: AppTheme.inputDecoration('Phone Number')
                              .copyWith(
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                          style: AppTheme.bodyMedium,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Include Activation Switch
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subscriptions,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add initial activation',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch(
                              value: includeActivation,
                              onChanged: (value) {
                                setState(() {
                                  includeActivation = value;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),

                      // Activation Content (conditionally shown)
                      if (includeActivation) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              76,
                              175,
                              79,
                            ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Initial Activation Details',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Activation Date Picker
                              buildDatePicker(
                                context: context,
                                setState: setState,
                                title: 'Activation Date',
                                selectedDate: activationDatePicker,
                                icon: Icons.calendar_month,
                                onDateSelected: (picked) {
                                  setState(() {
                                    activationDatePicker = picked;
                                  });
                                },
                              ),
                              SizedBox(height: 16),

                              // Subscription Type Dropdown
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedSubscriptionType,
                                  decoration: AppTheme.inputDecoration(
                                    'Subscription Type',
                                  ),
                                  dropdownColor: AppTheme.surfaceColor,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.accentColor,
                                  ),
                                  style: AppTheme.bodyMedium,
                                  items: [
                                    // Category A Header
                                    DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.local_offer,
                                              color: AppTheme.primaryColor,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'الاشتراك الوطني',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Category A Items
                                    ...subscriptionTypesA.map((String type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 24.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppTheme.secondaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                type,
                                                style: AppTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    // Divider
                                    DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: Divider(
                                        height: 1,
                                        color: AppTheme.borderColor,
                                        thickness: 1,
                                      ),
                                    ),

                                    // Category B Header
                                    DropdownMenuItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.cell_tower,
                                              color: AppTheme.accentColor,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'اشتراك البرج',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.accentColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Category B Items
                                    ...subscriptionTypesB.map((String type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 24.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                type,
                                                style: AppTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedSubscriptionType = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 20),

                              // Tower Dropdown
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedTowerType,
                                  decoration: AppTheme.inputDecoration('Tower'),
                                  dropdownColor: AppTheme.surfaceColor,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.accentColor,
                                  ),
                                  style: AppTheme.bodyMedium,
                                  items: towers.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.cell_tower,
                                            color: const Color.fromARGB(
                                              255,
                                              226,
                                              231,
                                              226,
                                            ),
                                            size: 18,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 24.0,
                                            ),
                                            child: Text(
                                              type,
                                              style: AppTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedTowerType = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 16),

                              // Payment Method Dropdown
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedPaymentMethod,
                                  decoration: AppTheme.inputDecoration(
                                    'Payment Method',
                                  ),
                                  dropdownColor: AppTheme.surfaceColor,
                                  icon: Icon(
                                    Icons.payment,
                                    color: AppTheme.successColor,
                                  ),
                                  style: AppTheme.bodyMedium,
                                  items: paymentMethods.map((String method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Row(
                                        children: [
                                          Icon(
                                            method == 'Cash'
                                                ? Icons.money
                                                : Icons.credit_card,
                                            color: AppTheme.successColor,
                                            size: 18,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            method,
                                            style: AppTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPaymentMethod = newValue!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 16),

                              // Price Paid TextField
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: pricePaidController,
                                  decoration:
                                      AppTheme.inputDecoration(
                                        'How much paid?',
                                      ).copyWith(
                                        prefixIcon: Icon(
                                          Icons.attach_money,
                                          color: AppTheme.successColor,
                                        ),
                                      ),
                                  style: AppTheme.bodyMedium,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Repayment Date Picker
                              buildDatePicker(
                                context: context,
                                setState: setState,
                                title: 'Repayment Date',
                                selectedDate: repaymentDate,
                                icon: Icons.schedule,
                                onDateSelected: (picked) {
                                  setState(() {
                                    repaymentDate = picked;
                                  });
                                },
                              ),
                              SizedBox(height: 16),

                              // Notes TextField
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: notesController,
                                  maxLines: 2,
                                  decoration: AppTheme.inputDecoration('Notes')
                                      .copyWith(
                                        prefixIcon: Icon(
                                          Icons.note,
                                          color: AppTheme.secondaryColor,
                                        ),
                                        alignLabelWithHint: true,
                                      ),
                                  style: AppTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: AppTheme.textButtonStyle,
                  child: Text('Cancel'),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                ElevatedButton(
                  style: AppTheme.primaryButtonStyle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8),
                      Text('Create User'),
                    ],
                  ),
                  onPressed: () {
                    // Validate input
                    if (userNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Please enter a user name'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                      return;
                    }

                    // Generate unique user ID (you might want to implement your own logic)
                    int userId = id;

                    // Create new user
                    User newUser = User(
                      userName: userNameController.text.trim(),
                      userId: userId,
                      phone: phoneController.text.trim(),
                    );

                    // Add activation if requested
                    if (includeActivation) {
                      double pricePaid =
                          double.tryParse(pricePaidController.text) ?? 0;
                      double fullPrice = newUser._getSubscriptionPrice(
                        selectedSubscriptionType,
                      );

                      Activations newActivation = Activations(
                        activationDate: activationDatePicker,
                        expiryDate: repaymentDate,
                        type: selectedSubscriptionType,
                        tower: selectedTowerType,
                        paymentMethod: selectedPaymentMethod,
                        status: true,
                        pricePaid: pricePaid,
                        payed: pricePaid >= fullPrice,
                        fullPrice: fullPrice,
                      );

                      newUser.addActivation(newActivation);
                      // Navigator.of(context).pop();

                      // Show success message
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('User created successfully!'),
                        backgroundColor: AppTheme.successColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text('Activation added successfully!'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                    Navigator.of(context).pop(newUser);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // You'll need to implement these helper methods for the activations dialog:

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No activations yet',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textHint),
          ),
          SizedBox(height: 8),
          Text(
            'Add the first activation to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  void _showDebtManagementDialog(BuildContext context, StateSetter setState) {
    // Implement debt management dialog here
    // This would allow users to make payments on debts
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debt Management'),

        content: Text('Debt management functionality would go here'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build date picker widget
  static Widget buildDatePicker({
    required BuildContext context,
    required StateSetter setState,
    required String title,
    required DateTime selectedDate,
    required IconData icon,
    required Function(DateTime) onDateSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: AppTheme.surfaceColor,
                    onSurface: AppTheme.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != selectedDate) {
            onDateSelected(picked);
          }
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.accentColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.labelMedium),
                    SizedBox(height: 4),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.textHint, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Edited showAddActivationDialog method
  Future<void> showAddActivationDialog(BuildContext context) async {
    // Initialize values
    activationDatePicker = DateTime.now();
    repaymentDate = DateTime.now().add(Duration(days: 30));
    pricePaidController.clear();
    notesController.clear();
    selectedSubscriptionType = 'A35';
    selectedPaymentMethod = 'Cash';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Add New Activation', style: AppTheme.titleLarge),
                ],
              ),
              content: SingleChildScrollView(
                child: _buildAddActivationContent(context, setState),
              ),
              actions: <Widget>[
                TextButton(
                  style: AppTheme.textButtonStyle,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: AppTheme.primaryButtonStyle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8),
                      Text('Activate'),
                    ],
                  ),
                  onPressed: () {
                    // Create new activation
                    double pricePaid =
                        double.tryParse(pricePaidController.text) ?? 0;
                    double fullPrice = _getSubscriptionPrice(
                      selectedSubscriptionType!,
                    );

                    Activations newActivation = Activations(
                      activationDate: activationDatePicker,
                      expiryDate: repaymentDate,
                      type: selectedSubscriptionType!,
                      tower: selectedTowerType!,
                      paymentMethod: selectedPaymentMethod,
                      status: true,
                      pricePaid: pricePaid,
                      payed: pricePaid >= fullPrice,
                      notes: notesController.text,
                      fullPrice: fullPrice,
                    );

                    addActivation(newActivation);
                    Navigator.of(context).pop();
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Activation added successfully!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Edited _buildAddActivationContent method
  Widget _buildAddActivationContent(
    BuildContext context,
    StateSetter setState,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: .1),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text('$userName ($userId)', style: AppTheme.bodyMedium),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Activation Date Picker - CHANGED: Now uses static method
          User.buildDatePicker(
            context: context,
            setState: setState,
            title: 'Activation Date',
            selectedDate: activationDatePicker,
            icon: Icons.calendar_month,
            onDateSelected: (picked) {
              setState(() {
                activationDatePicker = picked;
              });
            },
          ),
          SizedBox(height: 20),

          // Subscription Type Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedSubscriptionType,
              decoration: AppTheme.inputDecoration('Subscription Type'),
              dropdownColor: AppTheme.surfaceColor,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.accentColor),
              style: AppTheme.bodyMedium,
              items: [
                // Category A Header
                DropdownMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'الاشتراك الوطني',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category A Items
                ...subscriptionTypesA.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(type, style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }),

                // Divider
                DropdownMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Divider(
                    height: 1,
                    color: AppTheme.borderColor,
                    thickness: 1,
                  ),
                ),

                // Category B Header
                DropdownMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cell_tower,
                          color: AppTheme.accentColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'اشتراك البرج',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category B Items
                ...subscriptionTypesB.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(type, style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedSubscriptionType = newValue;
                  });
                }
              },
            ),
          ),
          SizedBox(height: 20),

          // Tower Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedTowerType,
              decoration: AppTheme.inputDecoration('Tower'),
              dropdownColor: AppTheme.surfaceColor,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.accentColor),
              style: AppTheme.bodyMedium,
              items: towers.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cell_tower,
                        color: const Color.fromARGB(255, 226, 231, 226),
                        size: 18,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: Text(type, style: AppTheme.bodyMedium),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedTowerType = newValue;
                  });
                }
              },
            ),
          ),
          SizedBox(height: 16),

          // Payment Method Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              decoration: AppTheme.inputDecoration('Payment Method'),
              dropdownColor: AppTheme.surfaceColor,
              icon: Icon(Icons.payment, color: AppTheme.successColor),
              style: AppTheme.bodyMedium,
              items: paymentMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentIcon(method),
                        color: AppTheme.successColor,
                        size: 18,
                      ),
                      SizedBox(width: 12),
                      Text(method, style: AppTheme.bodyMedium),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = newValue!;
                });
              },
            ),
          ),
          SizedBox(height: 20),

          // Price Paid TextField
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,

                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: pricePaidController,
              decoration: AppTheme.inputDecoration('How much paid?').copyWith(
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: AppTheme.successColor,
                ),
              ),
              style: AppTheme.bodyMedium,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 20),

          // Repayment Date Picker - CHANGED: Now uses static method
          User.buildDatePicker(
            context: context,
            setState: setState,
            title: 'Repayment Date',
            selectedDate: repaymentDate,
            icon: Icons.schedule,
            onDateSelected: (picked) {
              setState(() {
                repaymentDate = picked;
              });
            },
          ),
          SizedBox(height: 20),

          // Notes TextField
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: notesController,
              maxLines: 3,
              decoration: AppTheme.inputDecoration('Notes').copyWith(
                prefixIcon: Icon(Icons.note, color: AppTheme.secondaryColor),
                alignLabelWithHint: true,
              ),
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Show activations management dialog for this user
  Future<void> showActivationsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.subscriptions,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$userName\'s Activations',
                          style: AppTheme.titleMedium,
                        ),
                        Text(
                          '${activations.length} total • $activeActivationsCount active',
                          style: AppTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // Debt Summary Card
                    if (totalDebt > 0)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Outstanding Debt',
                                    style: AppTheme.labelMedium.copyWith(
                                      color: AppTheme.errorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalDebt.toStringAsFixed(2)}',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  _showDebtManagementDialog(context, setState),
                              icon: Icon(Icons.payment, size: 16),
                              label: Text('Manage Debts'),
                            ),
                          ],
                        ),
                      ),

                    // Activations List
                    Expanded(
                      child: activations.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: activations.length,
                              itemBuilder: (context, index) {
                                final activation = activations[index];
                                return _buildActivationCard(
                                  context,
                                  activation,
                                  index,
                                  setState,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: AppTheme.textButtonStyle,
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  style: AppTheme.primaryButtonStyle,
                  onPressed: () {
                    Navigator.of(context).pop();
                    showAddActivationDialog(context);
                  },
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add New'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper widget for date pickers
  // ignore: unused_element
  Widget _buildDatePicker({
    required BuildContext context,
    required StateSetter setState,
    required String title,
    required DateTime? selectedDate,
    required IconData icon,
    required Function(DateTime) onDateSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: AppTheme.cardColor,
                    onSurface: AppTheme.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppTheme.datePickerDecoration,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.labelMedium),
                    SizedBox(height: 4),
                    Text(
                      selectedDate != null
                          ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : 'Select Date',
                      style: selectedDate != null
                          ? AppTheme.bodyMedium
                          : AppTheme.hintStyle,
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for payment method icons
  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'mastercard':
        return Icons.credit_card;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  // Build activation card
  Widget _buildActivationCard(
    BuildContext context,
    Activations activation,
    int index,
    StateSetter setState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activation.hasDebt
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : AppTheme.borderColor,
          width: activation.hasDebt ? 2 : 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activation.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSubscriptionIcon(activation.type),
            color: activation.statusColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activation.type,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Expires: ${_formatDate(activation.expiryDate)}',
                    style: AppTheme.labelMedium,
                  ),
                ],
              ),
            ),
            if (activation.hasDebt)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Debt: \${activation.debtAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildStatusChip(activation.statusText, activation.statusColor),
              SizedBox(width: 8),
              _buildStatusChip(
                activation.paymentMethod,
                AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
        children: [
          _buildActivationDetails(context, activation, index, setState),
        ],
      ),
    );
  }

  // Build activation details
  Widget _buildActivationDetails(
    BuildContext context,
    Activations activation,
    int index,
    StateSetter setState,
  ) {
    return Column(
      children: [
        Divider(color: AppTheme.borderColor),
        SizedBox(height: 12),

        // Details Grid
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Activation Date',
                _formatDate(activation.activationDate),
                Icons.event_available,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Price Paid',
                '\${activation.pricePaid.toStringAsFixed(2)}',
                Icons.attach_money,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Full Price',
                '\${activation.fullPrice.toStringAsFixed(2)}',
                Icons.price_change,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Payment Status',
                activation.payed ? 'Fully Paid' : 'Pending',
                activation.payed ? Icons.check_circle : Icons.pending,
              ),
            ),
          ],
        ),

        if (activation.notes.isNotEmpty) ...[
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes:', style: AppTheme.labelMedium),
                SizedBox(height: 4),
                Text(activation.notes, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],

        SizedBox(height: 16),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (activation.hasDebt)
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () =>
                      _showPaymentDialog(context, activation, index, setState),
                  icon: Icon(Icons.payment, size: 16),
                  label: Text('Pay Debt'),
                ),
              ),
            if (activation.hasDebt) SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: AppTheme.primaryButtonStyle,
                onPressed: () => _showEditActivationDialog(
                  context,
                  activation,
                  index,
                  setState,
                ),
                icon: Icon(Icons.edit, size: 16),
                label: Text('Edit'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _confirmDelete(context, index, setState),
                icon: Icon(Icons.delete, size: 16),
                label: Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Payment Dialog for Debt Management
  Future<void> _showPaymentDialog(
    BuildContext context,
    Activations activation,
    int index,
    StateSetter parentSetState,
  ) async {
    TextEditingController paymentController = TextEditingController();
    double remainingDebt = activation.debtAmount;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.payment, color: AppTheme.successColor),
                  SizedBox(width: 12),
                  Text('Pay Debt', style: AppTheme.titleMedium),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription: ${activation.type}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Outstanding Debt: \${remainingDebt.toStringAsFixed(2)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: paymentController,
                    decoration: AppTheme.inputDecoration('Payment Amount')
                        .copyWith(
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: AppTheme.successColor,
                          ),
                          suffixText: 'USD',
                        ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            foregroundColor: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            paymentController.text = remainingDebt
                                .toStringAsFixed(2);
                          },
                          child: Text('Pay Full Amount'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: AppTheme.textButtonStyle,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: AppTheme.primaryButtonStyle,
                  onPressed: () {
                    double paymentAmount =
                        double.tryParse(paymentController.text) ?? 0;
                    if (paymentAmount > 0 && paymentAmount <= remainingDebt) {
                      // Update the activation with new payment
                      Activations updatedActivation = activation
                          .copyWithPayment(paymentAmount);
                      updateActivation(index, updatedActivation);
                      parentSetState(() {});

                      Navigator.of(context).pop();
                      _showSnackBar(
                        context,
                        'Payment of \${paymentAmount.toStringAsFixed(2)} recorded successfully!',
                      );
                    } else {
                      _showSnackBar(
                        context,
                        'Invalid payment amount',
                        isError: true,
                      );
                    }
                  },
                  child: Text('Record Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Debt Management Dialog
  Future<void> showDebtManagementDialog(
    BuildContext context,
    StateSetter parentSetState,
  ) async {
    List<Activations> debtActivations = this.debtActivations;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('Debt Management', style: AppTheme.titleMedium),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                // Summary
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Debts:', style: AppTheme.bodyLarge),
                      Text(
                        '\${totalDebt.toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Debt List
                Expanded(
                  child: ListView.builder(
                    itemCount: debtActivations.length,
                    itemBuilder: (context, index) {
                      final activation = debtActivations[index];
                      int originalIndex = activations.indexOf(activation);
                      return Card(
                        color: AppTheme.surfaceColor,
                        child: ListTile(
                          leading: Icon(
                            _getSubscriptionIcon(activation.type),
                            color: AppTheme.errorColor,
                          ),
                          title: Text(
                            activation.type,
                            style: AppTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            'Debt: \${activation.debtAmount.toStringAsFixed(2)}',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showPaymentDialog(
                                context,
                                activation,
                                originalIndex,
                                parentSetState,
                              );
                            },
                            child: Text('Pay'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: AppTheme.textButtonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Edit Activation Dialog (placeholder - implement based on your needs)
  Future<void> _showEditActivationDialog(
    BuildContext context,
    Activations activation,
    int index,
    StateSetter setState,
  ) async {
    // You can implement the edit dialog similar to add dialog
    // but pre-populate fields with current activation data
    // print('Edit activation: ${activation.type}');
  }

  // Confirm Delete Dialog
  Future<void> _confirmDelete(
    BuildContext context,
    int index,
    StateSetter setState,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text('Confirm Delete', style: AppTheme.titleMedium),
          content: Text(
            'Are you sure you want to delete this activation?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              onPressed: () {
                setState(() {
                  removeActivation(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show snack bar
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Helper Widgets
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: AppTheme.textHint),
          SizedBox(height: 16),
          Text(
            'No Activations Yet',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textHint),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first activation to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.secondaryColor),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.labelMedium),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Functions
  IconData _getSubscriptionIcon(String type) {
    if (type.contains('وطني') ||
        type.toLowerCase().contains('national') ||
        type.startsWith('A')) {
      return Icons.public;
    } else if (type.contains('برج') ||
        type.toLowerCase().contains('tower') ||
        type.startsWith('B')) {
      return Icons.cell_tower;
    }
    return Icons.subscriptions;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      userName: fields[0] as String,
      userId: fields[1] as int,
      phone: fields[2] as String,
      notes: fields[3] as String,
      activations: (fields[4] as List?)?.cast<Activations>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.activations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivationsAdapter extends TypeAdapter<Activations> {
  @override
  final int typeId = 0;

  @override
  Activations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activations(
      activationDate: fields[0] as DateTime,
      expiryDate: fields[1] as DateTime,
      type: fields[2] as String,
      paymentMethod: fields[3] as String,
      status: fields[4] as bool,
      pricePaid: fields[5] as double,
      payed: fields[6] as bool,
      notes: fields[7] as String,
      fullPrice: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Activations obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.activationDate)
      ..writeByte(1)
      ..write(obj.expiryDate)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.pricePaid)
      ..writeByte(6)
      ..write(obj.payed)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.fullPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Custom DateTime adapter
class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 2;

  @override
  DateTime read(BinaryReader reader) {
    return DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
