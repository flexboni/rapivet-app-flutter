import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/one_pet_data.dart';
import 'package:swork_raon/rapivet/main.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/2_2_Login_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';
import 'package:swork_raon/rapivet/sign_up.dart';

import '../common/rapivetStatics.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

TextEditingController emailController;
TextEditingController passwordController;
TextEditingController searchPasswordController;

GoogleSignIn _googleSignIn;

bool showSocialSignPopup = false;
bool isHidePassword = true;

class _LoginPageState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    isLoading = false;
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    showSocialSignPopup = false;
    emailController = TextEditingController();
    passwordController = TextEditingController();
    searchPasswordController = TextEditingController();

    // 필요없는듯
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print("here!!!!!!");
      print(account.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    double heightSize = MediaQuery.of(context).size.height;

    void handleHidePassword() {
      setState(() {
        isHidePassword = !isHidePassword;
      });
    }

    void clickLoginButton() async {
      setState(() {
        isLoading = true;
      });

      String token = await Api_manager()
          .login(emailController.text.trim(), passwordController.text.trim());

      // 로그인 실패
      if (token.isEmpty) {
        JToast().show_toast("Não foi possível fazer o Login.", true);

        setState(() {
          isLoading = false;
        });
      } else {
        // 로그인 성공 -- temp
        // load pet list
        List<one_pet_data> petData = await Api_manager().get_pet_list(token);
        rapivetStatics.pet_data_list = petData;

        Login_subFuncs().operate_after_login(context, token);
      }

      setState(() {
        isLoading = false;
      });
    }

    void clickSearchPassword() async {
      setState(() {
        isLoading = true;
      });

      String result =
          await Api_manager().search_pw(searchPasswordController.text.trim());
      if (result == "") {
        JToast().show_toast(
          "Impossível dar continuidade.",
          false,
        );
      } else if (result == "success") {
        JToast().show_toast(
          "Enviamos a senha provisória para o e-mail cadastrado. Com a senha provisória faça o login e recadastre a senha nova.",
          false,
        );
      } else {
        JToast().show_toast(result, true);
      }

      setState(() {
        isLoading = false;
      });
    }

    // TODO
    void onFacebookSignUp() async {
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
        isLoading = true;
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
        isLoading = false;
      });
    }

    void handleGoogleSignUp() async {
      setState(() {
        isLoading = true;
        showSocialSignPopup = false;
      });

      try {
        GoogleSignInAccount result = await _googleSignIn.signIn();
        await Login_subFuncs().operate_social_sign(
          context,
          result.email,
          result.displayName,
        );
      } catch (error) {
        JToast().show_toast("Impossível dar continuidade.", true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    void clickGoBack() => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MainPage(),
          ),
        );

    void showSearchPasswordDialog() {
      searchPasswordController.text = "";
      // TODO 개선하기
      showDialogPopup(
        context,
        widthSize,
        searchPasswordController,
        "Por favor insira seu e-mail.",
        "nome@email.com",
        () {
          clickSearchPassword();
        },
        () {},
        is_using_number_only: false,
        is_phone_number: false,
      );
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainPage()),
        );
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
                    width: widthSize,
                    child: Column(
                      children: [
                        Padding(padding: new EdgeInsets.all(53)),
                        Container(
                          width: widthSize * 0.9,
                          child: Text(
                            "Já sou cliente Rapivet",
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 17.5,
                              color: rapivetStatics.app_black,
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(12)),
                        get_explain_of_textfield_up(
                          widthSize,
                          "E-mail",
                        ),
                        Padding(padding: new EdgeInsets.all(2)),
                        get_one_textfield(
                          widthSize,
                          rapivetStatics.app_blue,
                          emailController,
                          "",
                        ),
                        Padding(padding: new EdgeInsets.all(2)),
                        get_explain_of_textfield_down(
                          widthSize,
                          "Ex. nome@email.com",
                        ),
                        Padding(padding: new EdgeInsets.all(8)),
                        get_explain_of_textfield_up(
                          widthSize,
                          "Sehna",
                        ),
                        Padding(padding: new EdgeInsets.all(2)),
                        get_one_textfield(
                          widthSize,
                          rapivetStatics.app_blue,
                          passwordController,
                          "",
                          is_password: isHidePassword,
                          is_to_show_pw_visibleMark: true,
                          Callback_click_pw_show_btn: handleHidePassword,
                        ),
                        Padding(padding: new EdgeInsets.all(15)),
                        get_one_btn(
                          widthSize * 0.9,
                          rapivetStatics.app_blue.withOpacity(0.8),
                          "Entar",
                          clickLoginButton,
                          in_height: 52,
                        ),
                        Padding(padding: new EdgeInsets.all(0)),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: rapivetStatics.app_bg,
                              width: 0,
                            ),
                          ),
                          onPressed: () {
                            showSearchPasswordDialog();
                          },
                          child: Text(
                            "Esqueci minha senha",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: rapivetStatics.app_blue,
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(15)),
                        Container(
                          width: widthSize * 0.9,
                          height: 52.88,
                          child: FittedBox(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: rapivetStatics.normal_ui_line_color,
                                  width: 1,
                                ),
                                backgroundColor: Colors.white,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showSocialSignPopup = true;
                                });
                              },
                              child: Container(
                                width: widthSize * 0.8,
                                alignment: Alignment.center,
                                height: 52.88,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "CONTINUAR COM    ",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                    ),
                                    Container(
                                      height: 24,
                                      child: Image.asset('assets/facebook.png'),
                                    ),
                                    Text(
                                      "   OU  ",
                                      style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: "Roboto",
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                    ),
                                    Container(
                                      height: 28,
                                      child: Image.asset('assets/google.png'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(7)),
                        Container(
                          width: widthSize * 0.9,
                          height: 52.88,
                          child: FittedBox(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: rapivetStatics.app_blue,
                                  width: 1,
                                ),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SignUpPage(SIGN_UP_MODE.SIGNUP),
                                  ),
                                );
                              },
                              child: Container(
                                width: widthSize * 0.8,
                                alignment: Alignment.center,
                                height: 52.88,
                                child: Text(
                                  "SOU UM NOVO USUARIO",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    //  fontWeight: FontWeight.bold,
                                    color: rapivetStatics.app_blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(15)),
                      ],
                    ),
                  ),
                ),
                get_upbar(
                  () {},
                  false,
                  "LOGIN",
                  in_width: widthSize,
                  callback_goBack: clickGoBack,
                ),
                Visibility(
                  visible: showSocialSignPopup,
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    width: widthSize,
                    height: heightSize,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: widthSize * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: new EdgeInsets.all(widthSize * 0.025),
                              ),
                              Container(
                                width: widthSize * 0.8,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: get_one_login_btn(
                                    widthSize * 0.8,
                                    Color.fromARGB(255, 59, 87, 157),
                                    Colors.white,
                                    'assets/facebook_sign.png',
                                    "   Cadastre-se no Facebook",
                                    () async {},
                                    in_height: 50,
                                  ),
                                ),
                              ),
                              Padding(padding: new EdgeInsets.all(5)),
                              Container(
                                width: widthSize * 0.8,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: get_one_login_btn(
                                    widthSize * 0.8,
                                    Colors.white,
                                    rapivetStatics.app_black,
                                    'assets/google_sign.png',
                                    "   Cadastre-se com o Google",
                                    () {
                                      handleGoogleSignUp();
                                    },
                                    in_height: 50,
                                    icon_height: 33,
                                  ),
                                ),
                              ),
                              Padding(padding: new EdgeInsets.all(5)),
                              Container(
                                width: widthSize * 0.8,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: get_one_login_btn(
                                    widthSize * 0.8,
                                    rapivetStatics.app_blue,
                                    Colors.white,
                                    '',
                                    "Fechar",
                                    () {
                                      setState(() {
                                        showSocialSignPopup = false;
                                      });
                                    },
                                    in_height: 50,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: new EdgeInsets.all(widthSize * 0.025),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                common_show_loading(
                  heightSize,
                  widthSize,
                  0,
                  this,
                  isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
