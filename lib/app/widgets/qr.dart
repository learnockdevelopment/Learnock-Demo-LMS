import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'dart:convert';
import '../../common/common.dart';
import '../../common/data/app_data.dart';
import '../../common/utils/constants.dart';
import '../../common/utils/http_handler.dart';
import '../models/category_model.dart';
import '../models/filter_model.dart';
import '../pages/main_page/main_page.dart';
import '../services/guest_service/categories_service.dart';

class ScannerPage extends StatefulWidget {
  static const String pageName = '/scanner';

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String url_check = '${Constants.baseUrl}qrcode/show';
  String url_enroll = '${Constants.baseUrl}qrcode';
  String qrResult = "Scan a QR code";
  bool isLoading = false;
  TextEditingController qrCodeController = TextEditingController();
  int? userId;
  int? courseId;
  int? bundleId;
  int? categoryId;

  List<CategoryModel> trendingCategories = [];
  List<CategoryModel> allCategories = [];
  List<FilterModel> filters = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadCourseAndBundleId();
    getCategoryID();
  }


  Future<void> _loadUserId() async {
    int? storedUserId = await AppData.getUserId();
    setState(() {
      userId = storedUserId;
    });
  }

  Future<void> scanQRCode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Line color
        'Cancel',   // Button text
        true,       // Show flash icon
        ScanMode.QR // Specify QR mode
    );

    if (barcode != '-1') {
      setState(() {
        qrResult = barcode;
        qrCodeController.text = barcode;
      });
      Sendforcheckusage(barcode);
    }
  }


  Future<int?> getCategoryID() async {
    // Retrieve the category ID from shared preferences
    int? categoryId = await AppData.getCategoryId();

    // Print the category ID if it is not null
    if (categoryId != null) {
      print('Retrieved Category ID: $categoryId');
    } else {
      print('Category ID not found.');
    }

    return categoryId;
  }

  Future<void> _loadCourseAndBundleId() async {
    // Load course ID and bundle ID from AppData
    int? storedCourseId = await AppData.getCourseId();
    int? storedBundleId = await AppData.getBundleId();

    setState(() {
      courseId = storedCourseId;
      bundleId = storedBundleId;
      print("course ID $courseId");
      print("Bundle ID $bundleId");
    });
  }


  Future<void> Sendforcheckusage(String qrCodeData) async {
    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'code': qrCodeData,
        'user_id': userId
      };
      final String apiKey = '1234';

      final response_check = await http.post(
        Uri.parse(url_check),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response_check.statusCode}');
      print('Response Body: ${response_check.body}');

      if (response_check.statusCode == 200) {
        final responseData = json.decode(response_check.body);

        if (responseData['status'] == 'qr_code_not_found') {
          showCustomAlertDialog(context, appText.qrNotFound, false);
          return;
        }

        final data = responseData['data'];
        if (data != null) {
          // Check if QR code is used
          if (data['is_used'] == 1) {
            if (data['user_id'] == userId) {
              showCustomAlertDialog(context, appText.usedByYou, false);
            } else if (data['user_id'] != null) {
              showCustomAlertDialog(context, appText.used, false);
            }
            return;
          }

          // Check expiration date
          if (data['expiration_date'] != null) {
            DateTime expirationDate = DateTime.parse(data['expiration_date']);
            DateTime currentDate = DateTime.now();

            if (expirationDate.isBefore(currentDate)) {
              showCustomAlertDialog(context, appText.expired, false);
}
            // Validate expiration date, ensuring it's not null before parsing
            if (data['expiration_date'] != null) {
              DateTime expirationDate = DateTime.parse(data['expiration_date']);
              DateTime currentDate = DateTime.now();

              if (expirationDate.isBefore(currentDate)) {
                showCustomAlertDialog(context, appText.expired, false);
              } else {
                int? categoryId = await AppData.getCategoryId();

                if (data['bundle_id'] == bundleId) {
                  bool isPurchased = await checkIfPurchased(bundleId.toString());
                  if (isPurchased) {
                    showCustomAlertDialog(context, appText.alreadyBought, false);
                  } else {
                    await sendToEnrollmentApi(qrCodeData, bundleId, 'bundle_id');
                  }
                } else if (data['category_id'] == categoryId) {
                  bool isPurchased = await checkIfPurchased(courseId.toString());
                  if (isPurchased) {
                    showCustomAlertDialog(context, appText.alreadyBought, false);
                  } else {
                    await sendToEnrollmentApi(qrCodeData, courseId, 'course_id');
                  }
                }
                else if (data['webinar_id'] == courseId || data['category_id'] == null) {
                  bool isPurchased = await checkIfPurchased(courseId.toString());
                  if (isPurchased) {
                    showCustomAlertDialog(context, appText.alreadyBought, false);
                  } else {
                    await sendToEnrollmentApi(qrCodeData, courseId, 'course_id');
                  }
                }else {
                  showCustomAlertDialog(context, appText.incorrectBundleCode, false);
                }

              }
                            return;
            }
               }

          int? categoryId = await AppData.getCategoryId();

          // Check Bundle ID
          if (data['bundle_id'] != null) {
            int retrievedBundleId = data['bundle_id'];
            print('Retrieved Bundle ID: $retrievedBundleId');

            if (retrievedBundleId == bundleId) {
              bool isPurchased = await checkIfPurchased(bundleId.toString());
              if (isPurchased) {
                showCustomAlertDialog(context, appText.qrPurchased, false);
                print('Bundle already purchased.');
              } else {
                // Send to Enrollment API if not purchased
                await sendToEnrollmentApi(qrCodeData, bundleId, 'bundle_id');
              }
              return;
            } else {
              showCustomAlertDialog(context, appText.incorrectBundleCode, false);
              print('Bundle ID does not match.');
              return;
            }
          }

          // Check Category ID
          if (data['category_id'] != null) {
            int retrievedCategoryId = data['category_id'];
            print('Retrieved Category ID: $retrievedCategoryId');

            if (retrievedCategoryId == categoryId) {
              bool isPurchased = await checkIfPurchased(courseId.toString());
              if (isPurchased) {
                showCustomAlertDialog(context, appText.qrPurchased, false);
                print('Course already purchased.');
              } else {
                // Send to Enrollment API if not purchased
                await sendToEnrollmentApi(qrCodeData, courseId, 'course_id');
              }
              return;
            } else {
              showCustomAlertDialog(context, appText.incorrectBundleCode, false);
              print('Category ID does not match.');
              return;
            }
          }

          // If both Bundle ID and Category ID checks are skipped or invalid
          showCustomAlertDialog(context, appText.serverError, false);
          print('Internal server error.');
        } else {
          print('No data returned for the QR code.');
          showCustomAlertDialog(context, appText.serverError, false);
        }
      } else {
        print('Failed to check QR code: ${response_check.statusCode}');
        showCustomAlertDialog(context, appText.serverError, false);
      }
    } catch (error) {
      showCustomAlertDialog(context, appText.serverError, false);
      print('Error occurred: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


// Function to check purchase status
  Future<bool> checkIfPurchased(String webinarIds) async {
    try {
      String url = '${Constants.baseUrl}panel/webinars/purchases';
      Response res = await httpGetWithToken(url);

      print('Response Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}'); // Print the entire response body for debugging

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        var purchases = jsonResponse['data']?['purchases'];
        print('Purchases Data: $purchases'); // Print all purchases

        if (purchases != null && purchases is List && purchases.isNotEmpty) {
          var webinarIdsList = webinarIds.split(',').map((id) => id.trim()).toList();
          print('Webinar IDs List to Check: $webinarIdsList'); // Print the list of webinar IDs you are checking against

          // Iterate and print every purchase for comparison
          bool matchFound = purchases.any((webinar) {
            var webinarId = webinar['webinar_id']?.toString().trim();
            print('Checking Webinar ID: $webinarId against List: $webinarIdsList'); // Log individual checks
            return webinarId != null && webinarIdsList.any((id) => id == webinarId);
          });

          if (matchFound) {
            print('Match found for one of the webinar IDs.');
          } else {
            print('No matching webinar ID found.');
          }

          return matchFound;
        } else {
          print('No purchases found or empty list.');
        }
      } else {
        print('API returned an unsuccessful response.');
      }
    } catch (error) {
      print('Error checking purchase status: $error');
    }
    return false; // Return false if no match or an error occurs
  }



  Future<void> sendToEnrollmentApi(String qrCodeData, dynamic id, String idType) async {
    try {
      final Map<String, dynamic> requestBody = {
        'code': qrCodeData,
        'user_id': userId,
         idType : id,
      };

      final String apiKey = '1234';

      final response = await http.post(
        Uri.parse(url_enroll),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Enrollment Success: $responseData');
        showCustomAlertDialog(context, appText.qrSuccess, true);
      } else {
        print('Enrollment failed: ${response.statusCode}');
        showCustomAlertDialog(context, appText.error, false);
      }
    } catch (error) {
      // Optionally handle the error here
      print('Error enrolling QR code: $error');
    }
  }

  void showCustomAlertDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: isSuccess
                    ? [Color(0xffe8f5e9), Color(0xffc8e6c9)]
                    : [Color(0xffffebee), Color(0xffffcdd2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess ? Color(0xff4caf50) : Color(0xFF2e71b8),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  isSuccess ? appText.success : appText.error,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Color(0xff388e3c) : Color(0xffd32f2f), // Green or Red
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  thickness: 1,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 10),
                // Message Section
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                // Button Section
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Color(0xff4caf50) : Color(0xFF2e71b8), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    appText.ok,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (isSuccess) {
                      nextRoute(MainPage.pageName, isClearBackRoutes: true);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = 'ar';
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(appText.scanner, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF2e71b8),
        centerTitle: true,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Directionality(
        textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Text(
                    appText.clickCamera,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),

                GestureDetector(
                  onTap: scanQRCode,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFF2e71b8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: qrCodeController,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      hintText: appText.qrHint,
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.qr_code, color: Color(0xFF2e71b8)), // Primary Color
                    ),
                    onChanged: (value) {
                      setState(() {
                        qrResult = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Sendforcheckusage(qrCodeController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2e71b8),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(appText.sendQr, style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

}