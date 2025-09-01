import 'package:hive_flutter/hive_flutter.dart';
import 'package:users_management/app_component/user.dart';
// import 'models.dart'; // Your models file

class HiveService {
  static const String usersBoxName = 'users_box';
  static late Box<User> _usersBox;

  // Initialize Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ActivationsAdapter());
    Hive.registerAdapter(DateTimeAdapter());
    
    // Open boxes
    _usersBox = await Hive.openBox<User>(usersBoxName);
  }

  // Store the entire users list
  static Future<void> storeUsersList(List<User> usersList) async {
    await _usersBox.clear(); // Clear existing data
    for (int i = 0; i < usersList.length; i++) {
      await _usersBox.put(i, usersList[i]);
    }
  }

  // Retrieve the entire users list
  static List<User> getUsersList() {
    return _usersBox.values.toList();
  }

  // Add a single user
  static Future<void> addUser(User user) async {
    await _usersBox.add(user);
  }

  // Update a user by index
  static Future<void> updateUser(int index, User user) async {
    await _usersBox.putAt(index, user);
  }

  // Delete a user by index
  static Future<void> deleteUser(int index) async {
    await _usersBox.deleteAt(index);
  }

  // Find user by userId
  static User? findUserById(String userId) {
    return _usersBox.values.firstWhere(
      (user) => user.userId == userId,
      orElse: () => throw StateError('User not found'),
    );
  }

  // Get user by index
  static User? getUserAt(int index) {
    return _usersBox.getAt(index);
  }

  // Get total users count
  static int getUsersCount() {
    return _usersBox.length;
  }

  // Clear all users
  static Future<void> clearAllUsers() async {
    await _usersBox.clear();
  }

  // Close the box (call when app closes)
  static Future<void> closeBox() async {
    await _usersBox.close();
  }
}