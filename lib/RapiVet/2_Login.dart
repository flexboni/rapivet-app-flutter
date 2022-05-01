import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/RapiVet/1_Welcome.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/2_2_Login_subfuncs.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/Api_manager.dart';

import '../0_CommonThisApp/rapivetStatics.dart';
import '3_Signup.dart';
import 'SceneSubFuncs/0_commonUI.dart';

class Login_scene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _login_scene_home();
}

TextEditingController _email_txtedit_control;
TextEditingController _pw_txtedit_control;
TextEditingController _pwSearch_email_txtedit_control;

GoogleSignIn _googleSignIn;

bool _is_social_sign_pop_on = false;

class _login_scene_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  bool _is_loading = false;

  @override
  void initState() {
    super.initState();

    _is_loading = false;
    //
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    _is_social_sign_pop_on = false;
    _email_txtedit_control = TextEditingController();
    _pw_txtedit_control = TextEditingController();
    _pwSearch_email_txtedit_control = TextEditingController();

    // 필요없는듯
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print("here!!!!!!");
      print(account.email);
    });
  }

  bool _is_hide_password = true;

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    callback_click_hidePassword() {
      print("callback_click_hidePassword");
      setState(() {
        _is_hide_password = !_is_hide_password;
      });
    }

    callback_click_loginBtn() async {
      print("callback_click_loginBtn");

      setState(() {
        _is_loading = true;
      });

      String token = await Api_manager().login(
          _email_txtedit_control.text.trim(), _pw_txtedit_control.text.trim());

      // 로그인 성공 -- temp
      if (token != "") {
        // load pet list
        List<one_pet_data> petDatas = await Api_manager().get_pet_list(token);
        rapivetStatics.pet_data_list = petDatas;

        Login_subFuncs().operate_after_login(context, token);
      }

      // 로그인 실패
      if (token == "") {
        JToast().show_toast("Não foi possível fazer o Login.", true);

        setState(() {
          _is_loading = false;
        });

        return;
      }
    }

    callback_click_search_pw() async {
      setState(() {
        _is_loading = true;
      });

      String result = await Api_manager()
          .search_pw(_pwSearch_email_txtedit_control.text.trim());
      print(result);

      if (result == "")
        JToast().show_toast("Impossível dar continuidade.", false);
      else if (result == "success")
        JToast().show_toast(
            "Enviamos a senha provisória para o e-mail cadastrado. Com a senha provisória faça o login e recadastre a senha nova.",
            false);
      else
        JToast().show_toast(result, true);

      setState(() {
        _is_loading = false;
      });
    }

    callback_sign_up_with_facebook() async {
      //   FacebookAuth.in
      // final facebookLogin = FacebookLogin();
      // facebookLogin.loginBehavior = FacebookLoginBehavior.nativeOnly;

      var result = null;

      if (Platform.isAndroid) {
        // Android-specific code
        // result = await facebookLogin.logInWithReadPermissions(['email']);
      } else if (Platform.isIOS) {
        //result = await facebookLogin.logIn(['email']);
        // iOS-specific code
      }
      // final result = await facebookLogin.logInWithReadPermissions(['email']); // android, facebook api 1.2.0
      //final result = await facebookLogin.logIn(['email']); // ios, facebook api 3.0.0
      //final result = await facebookLogin.logInWithReadPermissions(['email']); // android, facebook api 1.2.0
      //final result = await facebookLogin.logIn(['email']); // ios, facebook api 3.0.0

      String token = "";

      try {
        token = result.accessToken.token;
      } catch (e) {
        JToast().show_toast(
            "Você precisa instalar o aplicativo do Facebook para fazer o login usando a conta do Facebook.",
            false);
        return;
      }

      String url =
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=' +
              token;
      var uri = Uri.parse(url);
      final graphResponse = await phttp.get(uri);
      final profile = json.decode(graphResponse.body);
      print("profile!");
      print(profile);

      String email = profile["email"];
      String name = profile["name"];

      setState(() {
        _is_loading = true;
      });

      try {
        await Login_subFuncs().operate_social_sign(context, email, name);

        print("success login!!!");
      } catch (error) {
        print("failed login!!!");
        print(error);
        JToast().show_toast("Impossível dar continuidade.", true);
      }

      setState(() {
        _is_loading = false;
      });
    }

    callback_sign_up_with_google() async {
      setState(() {
        _is_loading = true;
        _is_social_sign_pop_on = false;
      });

      try {
        GoogleSignInAccount result = await _googleSignIn.signIn();

        await Login_subFuncs()
            .operate_social_sign(context, result.email, result.displayName);

        print("success login!!!");
      } catch (error) {
        print("failed login!!!");
        print(error);
        JToast().show_toast("Impossível dar continuidade.", true);
      }

      setState(() {
        _is_loading = false;
      });
    }

    callback_goback() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  WelcomePage() /*Api_test_scene()*/));
    }

    void _showDialog_search_pw() {
      _pwSearch_email_txtedit_control.text = "";
      show_dialog_popoup(context, s_width, _pwSearch_email_txtedit_control,
          "Por favor insira seu e-mail.", "nome@email.com", () {
        callback_click_search_pw();
      }, () {}, is_using_number_only: false, is_phone_number: false);
    }

    // void _showDialog() {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(30),
    //         ),
    //         title: new Text(
    //           "",
    //           style: TextStyle(fontSize: 1, fontWeight: FontWeight.normal),
    //         ),
    //         content: Container(
    //           height: 105,
    //           width: double.infinity,
    //           child: Column(
    //             children: [
    //               Container(
    //                 child: get_one_login_btn(s_width*0.8, Colors.blue, "Sign up with Facebook", (){})
    //               ),
    //               Padding(padding: new EdgeInsets.all(1)),
    //               Container(
    //                 child: SignInButton(
    //                   Buttons.GoogleDark,
    //                   onPressed: () async {
    //                     rapivetStatics.auth.userChanges();
    //
    //                     await rapivetStatics.auth.verifyPhoneNumber(
    //                       phoneNumber: '+82 10 5538 0188',
    //                       codeSent:
    //                           (String verificationId, int resendToken) async {
    //                         print(verificationId);
    //                         print(resendToken);
    //                         print("code sent!!!!");
    //
    //                         // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: "123456");
    //                         // UserCredential user = await auth.signInWithCredential(credential);
    //                         // print(user.additionalUserInfo);
    //                       },
    //                       codeAutoRetrievalTimeout: (String verificationId) {
    //                         // TIME OVER
    //                       },
    //                     );
    //
    //                     /*
    //                     try {
    //
    //                       GoogleSignInAccount result =await _googleSignIn.signIn();
    //
    //                       print(result.email);
    //                       print(result.displayName);
    //                       print("success login!!!");
    //
    //
    //                     } catch (error) {
    //                       print("failed login!!!");
    //                       print(error);
    //                     }
    //
    //                      */
    //                   },
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         actions: <Widget>[
    //           new FlatButton(
    //             child: new Text(
    //               "Close",
    //               style: TextStyle(color: rapivetStatics.app_blue),
    //             ),
    //             onPressed: () {
    //               Navigator.pop(context);
    //               FocusScope.of(context).unfocus();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.blueGrey,
    // ));

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    WelcomePage() /*Api_test_scene()*/));
        return false;
      },
      child: Scaffold(
          backgroundColor: rapivetStatics.app_bg,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: s_width,
                      child: Column(
                        children: [
                          Padding(padding: new EdgeInsets.all(53)),
                          Container(
                            width: s_width * 0.9,
                            child: Text(
                              "Já sou cliente Rapivet",
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 17.5,
                                  color: rapivetStatics.app_black),
                            ),
                          ),
                          Padding(padding: new EdgeInsets.all(12)),
                          get_explain_of_textfield_up(s_width, "E-mail"),
                          Padding(padding: new EdgeInsets.all(2)),
                          get_one_textfield(s_width, rapivetStatics.app_blue,
                              _email_txtedit_control, ""),
                          Padding(padding: new EdgeInsets.all(2)),
                          get_explain_of_textfield_down(
                              s_width, "Ex. nome@email.com"),
                          Padding(padding: new EdgeInsets.all(8)),
                          get_explain_of_textfield_up(s_width, "Sehna"),
                          Padding(padding: new EdgeInsets.all(2)),
                          get_one_textfield(s_width, rapivetStatics.app_blue,
                              _pw_txtedit_control, "",
                              is_password: _is_hide_password,
                              is_to_show_pw_visibleMark: true,
                              Callback_click_pw_show_btn:
                                  callback_click_hidePassword),
                          Padding(padding: new EdgeInsets.all(15)),
                          get_one_btn(
                              s_width * 0.9,
                              rapivetStatics.app_blue.withOpacity(0.8),
                              "Entar",
                              callback_click_loginBtn,
                              in_height: 52),
                          Padding(padding: new EdgeInsets.all(0)),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: rapivetStatics.app_bg, width: 0),
                              ),
                              onPressed: () {
                                _showDialog_search_pw();
                              },
                              child: Text(
                                "Esqueci minha senha",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: rapivetStatics.app_blue),
                              )),
                          Padding(padding: new EdgeInsets.all(15)),
                          Container(
                            width: s_width * 0.9,
                            height: 52.88,
                            child: FittedBox(
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: rapivetStatics
                                              .normal_ui_line_color,
                                          width: 1),
                                      backgroundColor: Colors.white,
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0))),
                                  onPressed: () {
                                    setState(() {
                                      _is_social_sign_pop_on = true;
                                    });
                                  },
                                  child: Container(
                                    width: s_width * 0.8,
                                    alignment: Alignment.center,
                                    height: 52.88,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "CONTINUAR COM    ",
                                          style: TextStyle(
                                              fontFamily: "Roboto",
                                              color: Colors.black
                                                  .withOpacity(0.4)),
                                        ),
                                        Container(
                                            height: 24,
                                            child: Image.asset(
                                                'assets/facebook.png')),
                                        Text(
                                          "   OU  ",
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: "Roboto",
                                              color: Colors.black
                                                  .withOpacity(0.4)),
                                        ),
                                        Container(
                                            height: 28,
                                            child: Image.asset(
                                                'assets/google.png')),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          Padding(padding: new EdgeInsets.all(7)),
                          Container(
                            width: s_width * 0.9,
                            height: 52.88,
                            child: FittedBox(
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                          color: rapivetStatics.app_blue,
                                          width: 1),
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0))),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                SignUp_scene(
                                                    SIGNUP_MODE.SIGNUP)));
                                  },
                                  child: Container(
                                    width: s_width * 0.8,
                                    alignment: Alignment.center,
                                    height: 52.88,
                                    child: Text(
                                      "SOU UM NOVO USUARIO",
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          //  fontWeight: FontWeight.bold,
                                          color: rapivetStatics.app_blue),
                                    ),
                                  )),
                            ),
                          ),
                          Padding(padding: new EdgeInsets.all(15)),
                          // Container(
                          //   width: s_width * 0.9,
                          //   height: 52.88,
                          //   child: FittedBox(
                          //     child: OutlinedButton(
                          //         style: OutlinedButton.styleFrom(
                          //             backgroundColor: Colors.white,
                          //             side: BorderSide(
                          //                 color: rapivetStatics.app_blue, width: 1),
                          //             shape: new RoundedRectangleBorder(
                          //                 borderRadius:
                          //                     new BorderRadius.circular(30.0))),
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (BuildContext context) =>
                          //                       RegisterPet_scene(COME_FROM.WELCOME,
                          //                           PET_REGISTER_MODE.ADD)));
                          //         },
                          //         child: Container(
                          //           width: s_width * 0.8,
                          //           alignment: Alignment.center,
                          //           height: 52.88,
                          //           child: Text(
                          //             "!!!! TEST - PET !!!",
                          //             style: TextStyle(
                          //                 fontFamily: "Roboto",
                          //                 //  fontWeight: FontWeight.bold,
                          //                 color: rapivetStatics.app_blue),
                          //           ),
                          //         )),
                          //   ),
                          // ),
                          // Padding(padding: new EdgeInsets.all(15)),
                          // Container(
                          //   width: s_width * 0.9,
                          //   height: 52.88,
                          //   child: FittedBox(
                          //     child: OutlinedButton(
                          //         style: OutlinedButton.styleFrom(
                          //             backgroundColor: Colors.white,
                          //             side: BorderSide(
                          //                 color: rapivetStatics.app_blue, width: 1),
                          //             shape: new RoundedRectangleBorder(
                          //                 borderRadius:
                          //                     new BorderRadius.circular(30.0))),
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (BuildContext context) =>
                          //                       Main_scene()));
                          //         },
                          //         child: Container(
                          //           width: s_width * 0.8,
                          //           alignment: Alignment.center,
                          //           height: 52.88,
                          //           child: Text(
                          //             "!!!! TEST - MAIN !!!",
                          //             style: TextStyle(
                          //                 fontFamily: "Roboto",
                          //                 //  fontWeight: FontWeight.bold,
                          //                 color: rapivetStatics.app_blue),
                          //           ),
                          //         )),
                          //   ),
                          // ),
                          // Padding(padding: new EdgeInsets.all(15)),
                          // Container(
                          //   width: s_width * 0.9,
                          //   height: 52.88,
                          //   child: FittedBox(
                          //     child: OutlinedButton(
                          //         style: OutlinedButton.styleFrom(
                          //             backgroundColor: Colors.white,
                          //             side: BorderSide(
                          //                 color: rapivetStatics.app_blue, width: 1),
                          //             shape: new RoundedRectangleBorder(
                          //                 borderRadius:
                          //                 new BorderRadius.circular(30.0))),
                          //         onPressed: () {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (BuildContext context) =>
                          //                       Api_test_scene()));
                          //         },
                          //         child: Container(
                          //           width: s_width * 0.8,
                          //           alignment: Alignment.center,
                          //           height: 52.88,
                          //           child: Text(
                          //             "!!!! TEST - API !!!",
                          //             style: TextStyle(
                          //                 fontFamily: "Roboto",
                          //                 //  fontWeight: FontWeight.bold,
                          //                 color: rapivetStatics.app_blue),
                          //           ),
                          //         )),
                          //   ),
                          // ),
                          // Padding(padding: new EdgeInsets.all(15)),
                        ],
                      ),
                    ),
                  ),
                  get_upbar(() {}, false, "LOGIN",
                      in_width: s_width, callback_goBack: callback_goback),
                  Visibility(
                      visible: _is_social_sign_pop_on,
                      child: Container(
                        color: Colors.black.withOpacity(0.8),
                        width: s_width,
                        height: s_height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: s_width * 0.9,
                              decoration: BoxDecoration(
                                //shape: BoxShape.circle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          new EdgeInsets.all(s_width * 0.025)),
                                  Container(
                                      width: s_width * 0.8,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: get_one_login_btn(
                                            s_width * 0.8,
                                            Color.fromARGB(255, 59, 87, 157),
                                            Colors.white,
                                            'assets/facebook_sign.png',
                                            "   Cadastre-se no Facebook",
                                            () async {
                                          // callback_sign_up_with_facebook();
                                        }, in_height: 50),
                                      )),
                                  Padding(padding: new EdgeInsets.all(5)),
                                  Container(
                                      width: s_width * 0.8,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: get_one_login_btn(
                                            s_width * 0.8,
                                            Colors.white,
                                            rapivetStatics.app_black,
                                            'assets/google_sign.png',
                                            "   Cadastre-se com o Google", () {
                                          callback_sign_up_with_google();
                                        }, in_height: 50, icon_height: 33),
                                      )),
                                  Padding(padding: new EdgeInsets.all(5)),
                                  Container(
                                      width: s_width * 0.8,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: get_one_login_btn(
                                            s_width * 0.8,
                                            rapivetStatics.app_blue,
                                            Colors.white,
                                            '',
                                            "Fechar", () {
                                          setState(() {
                                            _is_social_sign_pop_on = false;
                                          });
                                        }, in_height: 50),
                                      )),
                                  Padding(
                                      padding:
                                          new EdgeInsets.all(s_width * 0.025)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  common_show_loading(s_height, s_width, 0, this, _is_loading),
                ],
              ),
            ),
          )),
    );
  }
}
