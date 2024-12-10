import 'package:shared_preferences/shared_preferences.dart';

class AppData {


  // Save user_id in SharedPreferences
  static Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);  // Store user_id with a key
  }

  // Retrieve user_id from SharedPreferences
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');  // Retrieve user_id using the key
  }

  static Future saveAccessToken(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('access_token', data);
  }

  static Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('access_token') ?? '';
    return data;
  }


  static Future saveName(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('name', data);
  }

  static Future getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('name') ?? '';
    return data;
  }


  static Future saveCurrency(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('currency', data);
  }

  static Future getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('currency') ?? 'EGP';
    return data;
  }


   static Future<void> setCourseId(int? id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('courseId', id ?? 0); // Store as integer, 0 is the default if null
  }

  // Retrieve course ID
  static Future<int?> getCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('courseId');
  }

  // Store bundle ID
    static Future<void> setBundleId(int? id) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bundleId', id ?? 0); // Store as integer, 0 is the default if null
    }

    // Retrieve bundle ID
    static Future<int?> getBundleId() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt('bundleId');
    }


static Future<void> setCategoryId(int? id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('categoryId', id ?? 0);
  }

  static Future<int?> getCategoryId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('categoryId');
  }

  static Future saveIsFirst(bool data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('is_first', data);
  }

  static Future getIsFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first') ?? true;
  }




  // static String appName = 'Webinar';
  static bool canShowFinalizeSheet = true;
}
