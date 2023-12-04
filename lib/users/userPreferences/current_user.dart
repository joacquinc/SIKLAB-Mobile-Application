import "package:get/get.dart";
import 'package:siklabproject/users/model/user.dart';
import '../userPreferences/user_preferences.dart';

class CurrentUser extends GetxController{
  Rx<User> _currentUser = User(0,'','','','').obs;

  User get user => _currentUser.value;

  getUserInfo() async {
    User? getUserInfoFromLocalStorage = await RememberUser.readUser();
    _currentUser.value = getUserInfoFromLocalStorage!;
  }
}