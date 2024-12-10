import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/verify_code_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/home_page/termsWeb.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../common/components.dart';
import '../../../locator.dart';
import '../../providers/page_provider.dart';

class RegisterPage extends StatefulWidget {
  static const String pageName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isSendingData = false;

  CountryCode countryCode = CountryCode(
      code: "US",
      dialCode: "+1",
      flagUri: "${AppAssets.flags}en.png",
      name: "United States");

  String accountType = 'user';
  bool isLoadingAccountType = false;

  String? otherRegisterMethod;
  RegisterConfigModel? registerConfig;

  List<dynamic> selectRolesDuringRegistration = [];

  @override
  void initState() {
    super.initState();

    if (PublicData.apiConfigData['selectRolesDuringRegistration'] != null) {
      selectRolesDuringRegistration = ((PublicData
              .apiConfigData['selectRolesDuringRegistration']) as List<dynamic>)
          .toList();
    }

    // //print the entire apiConfigData to inspect its contents
    ////print"apiConfigData: ${PublicData.apiConfigData}");

// Check the register method and //print it along with the condition
    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    } else {
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }
// //print the determined method and values of isPhoneNumber and otherRegisterMethod
    ////print"register_method: ${PublicData.apiConfigData?['register_method']}");
    ////print"isPhoneNumber: $isPhoneNumber");
    ////print"otherRegisterMethod: $otherRegisterMethod");

    mailController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty) {
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

    phoneController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty) {
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

    passwordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty) {
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

    retypePasswordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty) {
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
    getAccountTypeFileds();
  }

  getAccountTypeFileds() async {
    if (mounted) {
      setState(() {
      });
    }

    registerConfig = await GuestService.registerConfig(accountType);

    if (mounted) {
      setState(() {
        isLoadingAccountType = false;
      });
    }
  }

  @override
  void dispose() {
    mailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    mailNode.dispose();
    phoneNode.dispose();
    passwordNode.dispose();
    retypePasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: directionality(
          child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: padding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(getSize().height * 0.10),

                  space(10),

                  // title
                  Row(
                    children: [
                      Text(
                        appText.createAccount,
                        style: style24Bold(),
                      ),
                      space(0, width: 4),
                      Transform.translate(
                        offset: Offset(0, -3), // Move the emoji up by 5 pixels
                        child: SvgPicture.asset(
                          AppAssets.signUp, // Your asset path
                          width: 30, // Adjust width as needed
                          height: 30, // Adjust height as needed
                        ),
                      ),
                    ],
                  ),

                  // desc
                  Text(
                    appText.createAccountDesc,
                    style: style14Regular().copyWith(color: greyA5),
                  ),

                  space(40),
                  // facebook
                  //     if(registerConfig?.showFacebookLoginButton ?? false)...{
                  //       socialWidget(AppAssets.facebookSvg, () async {
                  //         try{
                  //           final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);
                  //
                  //           if (result.status == LoginStatus.success) {
                  //             final AccessToken accessToken = result.accessToken!;
                  //
                  //             setState(() {
                  //               isSendingData = true;
                  //             });
                  //
                  //             FacebookAuth.instance.getUserData().then((value) async {
                  //
                  //               String email = value['email'];
                  //               String name = value['name'] ?? '';
                  //
                  //               try{
                  //                 bool res = await AuthenticationService.facebook(email, accessToken.tokenString, name);
                  //
                  //                 if(res){
                  //                   nextRoute(MainPage.pageName,isClearBackRoutes: true);
                  //                 }
                  //               }catch(_){}
                  //
                  //               setState(() {
                  //                 isSendingData = false;
                  //               });
                  //             });
                  //
                  //           } else {}
                  //         }catch(_){}
                  //       }),
                  //
                  //     }
                  space(10),

                  Text(
                    appText.accountType,
                    style: style14Regular().copyWith(color: greyB2),
                  ),

                  space(1),

                  // account types
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: borderRadius()),
                    width: getSize().width,
                    height: 52,
                    child: Row(
                      children: [
                        // student
                        AuthWidget.accountTypeWidget(
                            appText.student, accountType, PublicData.userRole,
                            () {
                          setState(() {
                            accountType = PublicData.userRole;
                          });
                          getAccountTypeFileds();
                        }),

                        // instructor
                        if (selectRolesDuringRegistration
                            .contains(PublicData.teacherRole)) ...{
                          AuthWidget.accountTypeWidget(appText.instrcutor,
                              accountType, PublicData.teacherRole, () {
                            setState(() {
                              accountType = PublicData.teacherRole;
                            });
                            getAccountTypeFileds();
                          }),
                        },

                        // organization
                        if (selectRolesDuringRegistration
                            .contains(PublicData.organizationRole)) ...{
                          AuthWidget.accountTypeWidget(appText.organization,
                              accountType, PublicData.organizationRole, () {
                            setState(() {
                              accountType = PublicData.organizationRole;
                            });
                            getAccountTypeFileds();
                          }),
                        }
                      ],
                    ),
                  ),

                  space(13),
                  Column(
                    children: [
                      Row(
                        children: [
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
                                borderRadius: borderRadius(),
                              ),
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
                          space(0, width: 3),
                          Expanded(
                              child: input(phoneController, phoneNode,
                                  appText.phoneNumber)),
                          if (otherRegisterMethod == "email")
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                appText.optional,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      space(16),
                      // Email Field
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: input(
                              mailController,
                              mailNode,
                              appText.yourEmail,
                              iconPathLeft: AppAssets.mailSvg,
                              leftIconSize: 14,
                            ),
                          ),
                          if (otherRegisterMethod == "phone")
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                appText.optional,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  space(16),
                  input(passwordController, passwordNode, appText.password,
                      iconPathLeft: AppAssets.passwordSvg,
                      leftIconSize: 14,
                      isPassword: true),

                  space(16),

                  input(retypePasswordController, retypePasswordNode,
                      appText.retypePassword,
                      iconPathLeft: AppAssets.passwordSvg,
                      leftIconSize: 14,
                      isPassword: true),

                  isLoadingAccountType
                      ? loading()
                      : Column(
                          children: [
                            ...List.generate(
                                registerConfig?.formFields?.fields?.length ?? 0,
                                (index) {
                              return registerConfig?.formFields?.fields?[index]
                                      .getWidget() ??
                                  const SizedBox();
                            })
                          ],
                        ),

                  space(32),

                  Center(
                    child: button(
                        onTap: () async {
                          if (!isEmptyInputs) {
                            if (registerConfig?.formFields?.fields != null) {
                              for (var i = 0;
                                  i <
                                      (registerConfig
                                              ?.formFields?.fields?.length ??
                                          0);
                                  i++) {
                                if (registerConfig?.formFields?.fields?[i]
                                            .isRequired ==
                                        1 &&
                                    registerConfig?.formFields?.fields?[i]
                                            .userSelectedData ==
                                        null) {
                                  if (registerConfig
                                          ?.formFields?.fields?[i].type !=
                                      'toggle') {
                                    showSnackBar(ErrorEnum.alert,
                                        '${appText.pleaseReview} ${registerConfig?.formFields?.fields?[i].getTitle()}');
                                    return;
                                  }
                                }
                              }
                            }

                            if (passwordController.text.trim().compareTo(
                                    retypePasswordController.text.trim()) ==
                                0) {
                              setState(() {
                                isSendingData = true;
                              });

                              if (registerConfig?.registerMethod == 'email') {
                                Map? res = await AuthenticationService
                                    .registerWithEmail(
                                        // email
                                        registerConfig?.registerMethod ?? '',
                                        mailController.text.trim(),
                                        passwordController.text.trim(),
                                        retypePasswordController.text.trim(),
                                        accountType,
                                        registerConfig?.formFields?.fields);

                                if (res != null) {
                                  if (res['step'] == 'stored' ||
                                      res['step'] == 'go_step_2') {
                                    nextRoute(VerifyCodePage.pageName,
                                        arguments: {
                                          'user_id': res['user_id'],
                                          'email': mailController.text.trim(),
                                          'password':
                                              passwordController.text.trim(),
                                          'retypePassword':
                                              retypePasswordController.text
                                                  .trim(),
                                        });
                                  } else if (res['step'] == 'go_step_3') {
                                    nextRoute(MainPage.pageName,
                                        arguments: res['user_id']);
                                  }
                                }
                              } else {
                                Map? res = await AuthenticationService
                                    .registerWithPhone(
                                        // mobile
                                        registerConfig?.registerMethod ?? '',
                                        countryCode.dialCode.toString(),
                                        phoneController.text.trim(),
                                        passwordController.text.trim(),
                                        retypePasswordController.text.trim(),
                                        accountType,
                                        registerConfig?.formFields?.fields);

                                if (res != null) {
                                  if (res['step'] == 'stored' ||
                                      res['step'] == 'go_step_2') {
                                    nextRoute(VerifyCodePage.pageName,
                                        arguments: {
                                          'user_id': res['user_id'],
                                          'countryCode':
                                              countryCode.dialCode.toString(),
                                          'phone': phoneController.text.trim(),
                                          'password':
                                              passwordController.text.trim(),
                                          'retypePassword':
                                              retypePasswordController.text
                                                  .trim()
                                        });
                                  } else if (res['step'] == 'go_step_3') {
                                    locator<PageProvider>()
                                        .setPage(PageNames.home);
                                    nextRoute(MainPage.pageName,
                                        arguments: res['user_id']);
                                  }
                                }
                              }

                              setState(() {
                                isSendingData = false;
                              });
                            }
                          }
                        },
                        width: getSize().width,
                        height: 52,
                        text: appText.createAnAccount,
                        bgColor: isEmptyInputs ? greyCF : green77(),
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData),
                  ),

                  space(35),

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
                  space(30),

                  // haveAnAccount
                  Column(
                    children: [
                      // Existing Account Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appText
                                .haveAnAccount, // Localized "Have an account?"
                            style: style16Regular(),
                          ),
                          SizedBox(width: 4), // Small space between text
                          GestureDetector(
                            onTap: () {
                              nextRoute(LoginPage.pageName,
                                  isClearBackRoutes: true);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              appText.login, // Localized "Login"
                              style: style16Regular().copyWith(
                                color: Colors
                                    .blue.shade800, // Highlight login link
                                fontWeight:
                                    FontWeight.bold, // Make the link bold
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10), // Spacing

                      // "Or" Divider
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

                      SizedBox(height: 25), // Spacing

                      // Google Sign-In Button
                        SizedBox(
                          width: double.infinity, // Full-width button
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
                                  bool res = await AuthenticationService.google(
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
                                    20), // Rounded corners
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
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }

  Widget socialWidget(String icon, Function onTap) {
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
