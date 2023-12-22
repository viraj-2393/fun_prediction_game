import 'package:shared_preferences/shared_preferences.dart';

setLoggedIn(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('loggedIn', value);
}

setId(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('id', id);
}

Future<bool?> getLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('loggedIn');
}

Future<String?> getId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('id');
}

removeId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('id');
}


removeLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('loggedIn');
}