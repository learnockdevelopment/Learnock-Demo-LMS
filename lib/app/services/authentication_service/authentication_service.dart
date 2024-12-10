import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/utils/app_text.dart';

class AuthenticationService {
  static Future google(BuildContext context, String email, String token,
      String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';
      String deviceId = await getDeviceId();
      String deviceType = Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Web'; // Adjust according to your platform needs

      // Prepare the request body
      Map<String, String> body = {
        'email': email,
        'name': name,
        'id': token,
        'device_id': deviceId,
        'device_type': deviceType,
      };

      ////print'Request Body: $body');
      // log('Request Body: $body');

      Response res = await httpPost(
        url,
        body,
      );

      ////print'Response Status: ${res.statusCode}');
      ////print'Response Body: ${res.body}');
      // log('Response Status: ${res.statusCode}');
      // log('Response Body: ${res.body}');
      var responseData = jsonDecode(res.body);

      if (responseData['success'] == false &&
          responseData['status'] == 'device_mismatch') {
        _showErrorDialog(context, responseData); // Show the error dialog
        return false; // Prevent login
      }
      // Check for a successful login
      if (res.statusCode == 200) {
        // Save the token and user_id (from response) for later use
        await AppData.saveAccessToken(responseData['data']['token']);
        int userId = responseData['data']['user_id']; // Assuming response contains 'user_id'
        // log('User ID: $userId');

        // You can store it in shared preferences or some other persistent storage
        await AppData.saveUserId(userId);  // This method should store user_id

        return true;
      } else {
        // log('Login failed with status: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      // log('Error: $e');
      return false;
    }
  }
  // static Future<bool> facebook(BuildContext context, String email, String token,
  //     String name) async {
  //   try {
  //     String url = '${Constants.baseUrl}facebook/callback';
  //     String deviceId = await getDeviceId();

  //     Response res = await httpPost(
  //       url,
  //       {
  //         'id': token,
  //         'name': name,
  //         'email': email,
  //         'device_id': deviceId, // Include Device ID in the body
  //       },
  //     );

  //     var jsonResponse = jsonDecode(res.body); // Decode the response body

  //     // Check for a device mismatch error
  //     if (jsonResponse['success'] == false &&
  //         jsonResponse['status'] == 'device_mismatch') {
  //       _showErrorDialog(context, jsonResponse); // Show the error dialog
  //       return false; // Prevent login
  //     }

  //     // Check for a successful login
  //     if (jsonResponse['success']) {
  //       await AppData.saveAccessToken(jsonResponse['data']['token']);
  //       return true;
  //     } else {
  //       // Handle other errors
  //       _showErrorDialog(context, jsonResponse); // Show the error dialog
  //       return false;
  //     }
  //   } catch (e) {
  //     // You might want to log the error or show a different dialog
  //     _showErrorDialog(context, {'message': 'An unexpected error occurred.'});
  //     return false;
  //   }
  // }

  static Future login(BuildContext context, String username,
      String password) async {
    try {
      String url = '${Constants.baseUrl}login';
      String deviceId = await getDeviceId();

      Response res = await httpPost(
          url,
          {
            'username': username,
            'password': password,
            'device_id': deviceId, // Include Device ID in the body
          }
      );

      // log('Response Body: ${res.body.toString()}');

      var jsonResponse = jsonDecode(res.body);

      // Check if login failed due to device mismatch
      if (jsonResponse['success'] == false && jsonResponse['status'] == 'device_mismatch') {
        _showErrorDialog(context, jsonResponse); // Show the error dialog
        return false; // Prevent login
      }

      // If login is successful
      if (jsonResponse['success']) {
        // Save the token and user_id
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        int userId = jsonResponse['data']['user_id']; // Assuming response contains 'user_id'
        // log('User ID: $userId');

        // Store the user_id in persistent storage
        await AppData.saveUserId(userId);  // This method should store user_id

        await AppData.saveName('');  // Save user name if needed
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        log('Response: ${jsonResponse.body}');

        return false;
      }
    } catch (e) {
      // log('Error: $e');
      return false;
    }
  }

  static Future<Map?> registerWithEmail(String registerMethod, String email,
      String password, String repeatPassword, String? accountType,
      List<Fields>? fields) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        "country_code": null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
      };

      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries(
                {
                  fields[i].id: (fields[i].type == 'toggle')
                      ? fields[i].userSelectedData == null ? 0 : 1
                      : fields[i].userSelectedData
                }.entries
            );
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(
          url,
          body
      );


      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] || jsonResponse['status'] == 'go_step_2' ||
          jsonResponse['status'] == 'go_step_3') {
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map?> registerWithPhone(String registerMethod,
      String countryCode, String mobile, String password, String repeatPassword,
      String? accountType, List<Fields>? fields) async {
    // try{
    String url = '${Constants.baseUrl}register/step/1';

    Map body = {
      "register_method": registerMethod,
      "country_code": countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
    };

    if (fields != null) {
      Map bodyFields = {};
      for (var i = 0; i < fields.length; i++) {
        if (fields[i].type != 'upload') {
          bodyFields.addEntries(
              {
                fields[i].id: (fields[i].type == 'toggle')
                    ? fields[i].userSelectedData == null ? 0 : 1
                    : fields[i].userSelectedData
              }.entries
          );
        }
      }

      body.addEntries({'fields': bodyFields.toString()}.entries);
    }

    Response res = await httpPost(
        url,
        body
    );

    ////printres.body);

    var jsonResponse = jsonDecode(res.body);
    if (jsonResponse['success'] || jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') { // || stored

      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status']
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }

    // }catch(e){
    //   return null;
    // }
  }

  static Future<bool> forgetPassword(String email) async {
    try {
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(
          url,
          {
            "email": email
          }
      );

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        ErrorHandler().showError(
            ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyCode(int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(
          url,
          {
            "user_id": userId.toString(),
            "code": code,
          }
      );

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(int userId, String name,
      String referralCode) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(
          url,
          {
            "user_id": userId.toString(),
            "full_name": name,
            "referral_code": referralCode
          }
      );


      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ??
          'Unknown Device ID'; // Unique iOS ID
    } else {
      return 'Unknown Device ID'; // Fallback for other platforms
    }
  }

  static void _showErrorDialog(BuildContext context, Map jsonResponse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xff2e71b8), size: 28),
              SizedBox(width: 8),
              Text(
            appText.appRestrict,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff2e71b8),
                ),
              ),
            ],
          ),
          content:  SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appText.deviceRestriction,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 15),
                Text(
                  appText.switchDevice,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                    appText.ok,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}