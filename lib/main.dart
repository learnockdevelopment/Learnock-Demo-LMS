import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/introduction_page/ip_empty_state_page.dart';
import 'package:webinar/app/pages/introduction_page/maintenance_page.dart';
import 'package:webinar/app/pages/introduction_page/splash_page.dart';
import 'package:webinar/app/pages/main_page/home_page/dashboard_page/reward_point_page.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meeting_details_page.dart';
import 'package:webinar/app/pages/main_page/home_page/payment_status_page/payment_status_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/pdf_viewer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/pages/offline_page/offline_list_course_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_content_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_course_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/widgets/qr.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/model/course_model_db.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/notification.dart';
import 'app/pages/authentication_page/forget_password_page.dart';
import 'app/pages/authentication_page/register_page.dart';
import 'app/pages/authentication_page/verify_code_page.dart';
import 'app/pages/main_page/blog_page/details_blog_page.dart';
import 'app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_details_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_student_page.dart';
import 'app/pages/main_page/classes_page/course_overview_page.dart';
import 'app/pages/main_page/home_page/comments_page/comment_details_page.dart';
import 'app/pages/main_page/home_page/comments_page/comments_page.dart';
import 'app/pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import 'app/pages/main_page/home_page/favorites_page/favorites_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_history_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_overview_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'app/pages/main_page/home_page/assignments_page/submissions_page.dart';
import 'app/pages/main_page/home_page/cart_page/bank_accounts_page.dart';
import 'app/pages/main_page/home_page/cart_page/cart_page.dart';
import 'app/pages/main_page/home_page/cart_page/checkout_page.dart';
import 'app/pages/main_page/home_page/financial_page/financial_page.dart';
import 'app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'app/pages/main_page/home_page/notification_page.dart';
import 'app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/forum_answer_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/search_forum_page.dart';
import 'app/pages/main_page/home_page/single_course_page/learning_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_content_page/single_content_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'app/pages/main_page/home_page/support_message_page/conversation_page.dart';
import 'app/pages/main_page/home_page/support_message_page/support_message_page.dart';
import 'app/pages/main_page/home_page/termsWeb.dart';
import 'app/pages/main_page/main_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_info_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import 'app/pages/main_page/providers_page/user_profile_page/user_profile_page.dart';
import 'app/pages/main_page/home_page/search_page/result_search_page.dart';
import 'app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'app/providers/app_language_provider.dart';
import 'app/providers/filter_course_provider.dart';
import 'app/providers/page_provider.dart';
import 'app/providers/providers_provider.dart';
import 'app/providers/user_provider.dart';
import 'common/common.dart';
import 'locator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:root_check/root_check.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // showFlutterNotification(message);
  // log('Handling a background message ${message.messageId}');
  // ////print'notif +: ${message.data}');
  // ////print'message--');
}

void main() async {
  // debugRepaintRainbowEnabled = true;
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  Hive.registerAdapter(CourseModelDBAdapter());
  await locatorSetup();
  await locator<AppLanguage>().getLanguage();
  await initializeDateFormatting();
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  await initializeApp();
  await setupFlutterNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // ////print'message-');
    showFlutterNotification(message);
  });
  // FirebaseMessaging.instance.getToken().then((value) {
  //   ////print'token : ${value}');
  // });
  runApp(MyApp(
    isEmulator: deviceStatus['isEmulator'] ?? false,
    isRooted: deviceStatus['isRooted'] ?? false,
    isDeveloper: deviceStatus['isDeveloper'] ?? false,
  ));
}

late Map<String, bool> deviceStatus;

Future<void> initializeApp() async {
  await screenRestrictions();
  await checkRestrictions();
}

Future<void> screenRestrictions() async {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

Future<void> checkRestrictions() async {
  deviceStatus = {
    'isRooted': await isRooted(),
    'isEmulator': await isEmulator(),
    'isDeveloper': await isDeveloper(),

  };

  if (deviceStatus.values.any((status) => status)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showBlockingAlert();
    });
  }
}

void showBlockingAlert() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('en'), // Change to 'en' or any LTR language code
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar'), // RTL Language
        Locale('en'), // LTR Language
      ],
      home: Directionality(
        textDirection: _getTextDirection(Locale('en')), // Set dynamically
        child: Scaffold(
          backgroundColor: Color(0xff2e71b8),
          body: Center(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Color(0xff2e71b8),
              title: Text(
                appText.appRestrict,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              content: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xff2e71b8), // Primary color
                      size: 80.0,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      appText.restriction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      appText.callSupport,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2e71b8), // Primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text(
                    appText.ok,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
TextDirection _getTextDirection(Locale locale) {
  if (locale.languageCode == 'ar') {
    // RTL languages like Arabic and Hebrew
    return TextDirection.rtl;
  } else {
    // LTR for other languages like English
    return TextDirection.ltr;
  }
}


Future<bool> isDeveloper() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // debugPrint("Device Info: Model=${androidInfo.model}, Manufacturer=${androidInfo.manufacturer}, IsPhysicalDevice=${androidInfo.isPhysicalDevice}");
      final debugKeywords = ['test-keys', 'debug', 'generic', 'sdk', 'google','adb', 'USB', 'debugging', 'Logger', 'GPU'];
      final containsDebugKeywords = debugKeywords.any((keyword) =>
      androidInfo.model.toLowerCase().contains(keyword) ||
          androidInfo.manufacturer.toLowerCase().contains(keyword));
      // debugPrint("Contains debug keywords: $containsDebugKeywords");
      if (containsDebugKeywords) {
        return true; // Emulator detected
      }
      // debugPrint("Checking Developer Mode using MethodChannel.");
      const platform = MethodChannel('developer_mode_check');
      final isDeveloper = await platform.invokeMethod<bool>(
          'isDeveloper') ??
          false;
      // debugPrint("Developer Mode enabled: $isDeveloper");
      if (isDeveloper) {
        return true;
      }
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // debugPrint("Device Info: IsPhysicalDevice=${iosInfo.isPhysicalDevice}");
      if (!iosInfo.isPhysicalDevice) {
        // debugPrint("Simulator detected on iOS.");
        return true;
      }
    }
    // debugPrint("Checking kDebugMode.");
    if (kDebugMode) {
      // debugPrint("App is in debug mode.");
      return true;
    }
    // debugPrint("No developer environment detected.");
    return false;
  } catch (e) {
    // debugPrint("Error checking developer options: $e");
    return false;
  }
}


Future<bool> isRooted() async {
  try {
    bool isRooted = await RootCheck.isRooted ?? false;
    return isRooted;
  } catch (e) {
    ////print"Error while checking root status: $e");
    return false;
  }
}

Future<bool> isEmulator() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice == false;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice == false;
    }
  } catch (e) {
    ////print"Error checking device type: $e");
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key,
    required this.isEmulator,
    required this.isRooted,
    required this.isDeveloper,
  }) : super(key: key);

  final bool isEmulator;
  final bool isRooted;
  final bool isDeveloper;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => locator<AppLanguageProvider>()),
        ChangeNotifierProvider(create: (context) => locator<PageProvider>()),
        ChangeNotifierProvider(create: (context) => locator<FilterCourseProvider>()),
        ChangeNotifierProvider(create: (context) => locator<ProvidersProvider>()),
        ChangeNotifierProvider(create: (context) => locator<UserProvider>()),
        ChangeNotifierProvider(create: (context) => locator<DrawerProvider>()),
      ],
      child: MaterialApp(
        title: appText.webinar,
        navigatorKey: navigatorKey,
        navigatorObservers: <NavigatorObserver>[Constants.singleCourseRouteObserver, Constants.contentRouteObserver],
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        theme: ThemeData(
          useMaterial3: false,

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          scaffoldBackgroundColor: greyFA,

        ),

        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
        initialRoute: SplashPage.pageName,
        routes: {
          TermsPage.pageName: (context) => TermsPage(
            url: ModalRoute.of(context)?.settings.arguments as String,),
          MainPage.pageName : (context) => const MainPage(),
          SplashPage.pageName : (context) => const SplashPage(),
          IntroPage.pageName : (context) => const IntroPage(),
          ScannerPage.pageName : (context) =>  ScannerPage(),
          LoginPage.pageName : (context) => const LoginPage(),
          RegisterPage.pageName : (context) => const RegisterPage(),
          VerifyCodePage.pageName : (context) => const VerifyCodePage(),
          ForgetPasswordPage.pageName : (context) => const ForgetPasswordPage(),
          FilterCategoryPage.pageName : (context) => const FilterCategoryPage(),
          SuggestedSearchPage.pageName : (context) => const SuggestedSearchPage(),
          ResultSearchPage.pageName : (context) => const ResultSearchPage(),
          DetailsBlogPage.pageName : (context) => const DetailsBlogPage(),
          SingleCoursePage.pageName : (context) => const SingleCoursePage(),
          LearningPage.pageName : (context) => const LearningPage(),
          SearchForumPage.pageName : (context) => const SearchForumPage(),
          ForumAnswerPage.pageName : (context) => const ForumAnswerPage(),
          NotificationPage.pageName : (context) => const NotificationPage(),
          CartPage.pageName : (context) => const CartPage(),
          CheckoutPage.pageName : (context) => const CheckoutPage(),
          SingleContentPage.pageName : (context) => const SingleContentPage(),
          WebViewPage.pageName : (context) => const WebViewPage(),
          BankAccountsPage.pageName : (context) => const BankAccountsPage(),
          UserProfilePage.pageName : (context) => const UserProfilePage(),
          AssignmentsPage.pageName : (context) => const AssignmentsPage(),
          AssignmentOverviewPage.pageName : (context) => const AssignmentOverviewPage(),
          SubmissionsPage.pageName : (context) => const SubmissionsPage(),
          AssignmentHistoryPage.pageName : (context) => const AssignmentHistoryPage(),
          FinancialPage.pageName : (context) => const FinancialPage(),
          CourseOverviewPage.pageName : (context) => const CourseOverviewPage(),
          MeetingsPage.pageName : (context) => const MeetingsPage(),
          MeetingDetailsPage.pageName : (context) => const MeetingDetailsPage(),
          CommentsPage.pageName : (context) => const CommentsPage(),
          CommentDetailsPage.pageName : (context) => const CommentDetailsPage(),
          SettingPage.pageName : (context) => const SettingPage(),
          QuizzesPage.pageName : (context) => const QuizzesPage(),
          QuizInfoPage.pageName : (context) => const QuizInfoPage(),
          QuizPage.pageName : (context) => const QuizPage(),
          CertificatesPage.pageName : (context) => const CertificatesPage(),
          CertificatesDetailsPage.pageName : (context) => const CertificatesDetailsPage(),
          CertificatesStudentPage.pageName : (context) => const CertificatesStudentPage(),
          SubscriptionPage.pageName : (context) => const SubscriptionPage(),
          FavoritesPage.pageName : (context) => const FavoritesPage(),
          DashboardPage.pageName : (context) => const DashboardPage(),
          SupportMessagePage.pageName : (context) => const SupportMessagePage(),
          ConversationPage.pageName : (context) => const ConversationPage(),
          PdfViewerPage.pageName : (context) => const PdfViewerPage(),
          RewardPointPage.pageName : (context) => const RewardPointPage(),
          MaintenancePage.pageName : (context) => const MaintenancePage(),
          PaymentStatusPage.pageName : (context) => const PaymentStatusPage(),
          IpEmptyStatePage.pageName : (context) => const IpEmptyStatePage(),
          // offline pages...
          InternetConnectionPage.pageName : (context) => const InternetConnectionPage(),
          OfflineListCoursePage.pageName : (context) => const OfflineListCoursePage(),
          OfflineSingleCoursePage.pageName : (context) => const OfflineSingleCoursePage(),
          OfflineSingleContentPage.pageName : (context) => const OfflineSingleContentPage(),
        },


      ),
    );
  }
}

