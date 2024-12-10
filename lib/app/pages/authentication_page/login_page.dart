import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/pages/authentication_page/forget_password_page.dart';
import 'package:webinar/app/pages/authentication_page/register_page.dart';
import 'package:webinar/app/pages/main_page/home_page/home_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/locator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import '../../widgets/authentication_widget/country_code_widget/code_country.dart';
import '../main_page/home_page/termsWeb.dart';

class LoginPage extends StatefulWidget {
  static const String pageName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();

  String? otherRegisterMethod;
  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isSendingData = false;
  bool isLoading = true;  // New variable for loading state

  CountryCode countryCode = CountryCode(
      code: "US",
      dialCode: "+1",
      flagUri: "${AppAssets.flags}en.png",
      name: "United States");

  @override
  void initState() {
    super.initState();

    // Simulating data loading (you can replace this with actual data loading logic)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Simulate fetching data or fetch actual data here
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
          isLoading = false; // Update loading state when done
        });
      }} catch (e) {
        if (mounted) {
          setState(() {
          isLoading = false;
        });
      }}
    });

    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false; // Default to email
      otherRegisterMethod = 'email'; // Set default method to email
    } else {
      isPhoneNumber = true; // Default to phone
      otherRegisterMethod = 'phone'; // Set default method to phone
    }

    // Add listener to mailController
    mailController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });

    // Add listener to passwordController
    passwordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nextRoute(MainPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: directionality(
          child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              AppAssets.introBgPng,
              width: getSize().width,
              height: getSize().height,
              fit: BoxFit.cover,
            )),
            Positioned.fill(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: padding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(getSize().height * .11),

                  // title
                  Row(
                    children: [
                      Text(
                        appText.welcomeBack,
                        style: style24Bold(),
                      ),
                      SizedBox(width: 7), // Adjust space between text and emoji
                      Transform.translate(
                        offset: Offset(0, -8),  // Move the emoji up by 5 pixels
                        child: SvgPicture.asset(
                          AppAssets.emoji2Svg,  // Your asset path
                          width: 30,             // Adjust width as needed
                          height: 30,            // Adjust height as needed
                        ),
                      ),
                    ],
                  ),
                  // desc
                  Text(
                    appText.welcomeBackDesc,
                    style: style14Regular().copyWith(color: greyA5),
                  ),

                  space(50),
                  // Other Register Method
                    space(15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: borderRadius(),
                      ),
                      width: getSize().width,
                      height: 52,
                      child: Row(
                        children: [
                          // email
                          AuthWidget.accountTypeWidget(
                            appText.email,
                            otherRegisterMethod ?? 'email', // Default to email if null
                            'email',
                                () {
                              setState(() {
                                otherRegisterMethod = 'email';  // Switch to email
                                isPhoneNumber = false; // Ensure it's set to email
                                mailController.clear(); // Clear the email field
                              });
                            },
                          ),

                          // phone
                          AuthWidget.accountTypeWidget(
                            appText.phone,
                            otherRegisterMethod ?? 'phone', // Default to phone if null
                            'phone',
                                () {
                              setState(() {
                                otherRegisterMethod = 'phone';  // Switch to phone
                                isPhoneNumber = true; // Ensure it's set to phone
                                mailController.clear(); // Clear the phone field (optional)
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    space(15),

                  // input
                  Column(
                    children: [
                      if (isPhoneNumber) ...{
                        // phone input
                        Row(
                          children: [
                            // country code
                            GestureDetector(
                              onTap: () async {
                                CountryCode? newData =
                                    await RegisterWidget.showCountryDialog();

                                if (newData != null) {
                                  countryCode = newData;
                                  setState(() {});
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: borderRadius()),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: borderRadius(radius: 50),
                                  child: Image.asset(
                                    countryCode.flagUri ?? '',
                                    width: 21,
                                    height: 19,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            space(0, width: 15),

                            Expanded(
                                child: input(mailController, mailNode,
                                    appText.phoneNumber))
                          ],
                        )
                      } else ...{
                        input(mailController, mailNode, appText.email,
                            iconPathLeft: AppAssets.mailSvg, leftIconSize: 14),
                      },
                      space(16),
                      input(passwordController, passwordNode, appText.password,
                          iconPathLeft: AppAssets.passwordSvg,
                          leftIconSize: 14,
                          isPassword: true),
                    ],
                  ),

                  space(35),

                  // button
                  Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Adjust height to children
                      children: [
                        // Login Button
                        SizedBox(
                          width: double.infinity, // Takes up the maximum width
                          child: button(
                            onTap: () async {
                              FocusScope.of(context).unfocus();

                              if (mailController.text.trim().isNotEmpty &&
                                  passwordController.text.trim().isNotEmpty) {
                                setState(() {
                                  isSendingData = true;
                                });

                                bool res = await AuthenticationService.login(
                                  context,
                                  '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}',
                                  passwordController.text.trim(),
                                );

                                setState(() {
                                  isSendingData = false;
                                });

                                if (res) {
                                  await FirebaseMessaging.instance
                                      .deleteToken();
                                  locator<PageProvider>()
                                      .setPage(PageNames.home);
                                  nextRoute(MainPage.pageName,
                                      isClearBackRoutes: true);
                                }
                              }
                            },
                            width: MediaQuery.of(context).size.width *
                                0.9, // 90% of the screen width
                            height: 52,
                            text: appText.login,
                            bgColor: isEmptyInputs ? greyCF : green77(),
                            textColor: Colors.white,
                            borderColor: Colors.transparent,
                            isLoading: isSendingData,
                          ),
                        ),

                        SizedBox(height: 30), // Spacing

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                appText.or, // Localized "or"
                                style: style16Regular(),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30), // Spacing

                        // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () async {
                                final GoogleSignInAccount? gUser =
                                    await GoogleSignIn().signIn();
                                final GoogleSignInAuthentication gAuth =
                                    await gUser!.authentication;

                                if (gAuth.accessToken != null) {
                                  setState(() {
                                    isSendingData = true;
                                  });

                                  try {
                                    bool res =
                                        await AuthenticationService.google(
                                      context,
                                      gUser.email,
                                      gAuth.accessToken ?? '',
                                      gUser.displayName ?? '',
                                    );

                                    if (res) {
                                      await FirebaseMessaging.instance
                                          .deleteToken();
                                      nextRoute(MainPage.pageName,
                                          isClearBackRoutes: true);
                                    }
                                  } catch (_) {}

                                  setState(() {
                                    isSendingData = false;
                                  });
                                }
                              },

                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.blue.shade800, // Google-like color
                                  borderRadius: BorderRadius.circular(
                                      16), // Rounded corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3), // Shadow position
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.googleSvg, // Google icon
                                      height: 24,
                                      width: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      appText.googleSign,
                                      style: TextStyle(
                                        color: Colors.white, // White text color
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  space(50),

                  // termsPoliciesDesc
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Here, we're passing the URL directly
                        nextRoute(
                          TermsPage.pageName,
                          arguments:
                          '${Constants.dommain}/pages/terms', // URL to be passed
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        appText.termsPoliciesDesc,
                        style: TextStyle(
                          color: Colors.blue
                              .shade800, // Highlight login link, // Set link color
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Adjust size as needed
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  space(50),

                  // haveAnAccount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appText.dontHaveAnAccount,
                        style: style16Regular(),
                      ),
                      space(0, width: 2),
                      GestureDetector(
                        onTap: () {
                          nextRoute(RegisterPage.pageName,
                              isClearBackRoutes: true);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          appText.signup, // Localized "Login"
                          style: style16Regular().copyWith(
                            color: Colors
                                .blue.shade800, // Highlight login link
                            fontWeight:
                            FontWeight.bold, // Make the link bold
                          ),
                        ),
                      )
                    ],
                  ),

                  space(25),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        nextRoute(ForgetPasswordPage.pageName);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        appText.forgetPassword,
                        style: style16Regular().copyWith(
                        color: Colors
                            .blue.shade800, // Highlight login link
                        fontWeight:
                        FontWeight.bold, // Make the link bold
                      ),
                    ),
                  ),
                  ),
                  space(25),
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }
  @override
  void dispose() {
    // Remove listeners in dispose() to prevent memory leaks
    mailController.removeListener(() {});
    passwordController.removeListener(() {});

    // Dispose controllers and focus nodes
    mailController.dispose();
    mailNode.dispose();
    passwordController.dispose();
    passwordNode.dispose();

    super.dispose();
  }
  socialWidget(String icon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(radius: 16),
        ),
        child: SvgPicture.asset(
          icon,
          width: 30,
        ),
      ),
    );
  }
}
