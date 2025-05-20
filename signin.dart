import 'dart:convert';
import 'dart:math';

import 'package:debate/src/route/route_name.dart';
import 'package:debate/src/views/screens/homepage.dart';
import 'package:debate/src/views/screens/notification_services.dart';
import 'package:debate/src/views/screens/signup.dart';
import 'package:debate/src/views/screens/forgotpassword_page.dart';
import 'package:debate/src/views/utils/global.dart' as glb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:debate/src/services/auth_service.dart' as auth_service;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  NotificationServices _notificationServices = NotificationServices();
  late DateTime currentBackPressTime;
  final _signInFormKey = GlobalKey<FormState>();
  bool passwordVisible = false;

  TextEditingController _usrNm_cont = TextEditingController();
  TextEditingController _Pswd_cont = TextEditingController();
  String usrNm = ""; //login username
  String Pswd = ""; //login password
  String email = "";
  String displayName = "";
  String passs = ""; // google signin password
  String usrname = ""; // google signin username
  String photoUrl = "";
  String name = "";
  String result = "";

  TextEditingController backendUrlCont = TextEditingController();
  TextEditingController jitsiUrlCont = TextEditingController();
  String backendUrl = "";
  String jitsiUrl = "";

  @override
  void initState() {
    super.initState();
    glb.profile_photo_uri = "";
  }

  googlesignin() async {
    print('google Signin method called');
    GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      print('inside try');
      var result = await _googleSignIn.signIn();
      print('after result');
      final ggAuth = await result!.authentication;
      print('google signin IdToken is ::  ${ggAuth.idToken}');
      print('google signin accessToken is ::  ${ggAuth.accessToken}');
      print('result google = $result');
      String googleusername = "";
      String googlepassword = "";

      if (result != null) {
        email = result.email;
        print('email is : $email');
        var isEmailRegistered = await checkEmailRegistered(email);
        if (isEmailRegistered) {
          googleusername = result.email.split('@').first;
          googlepassword = result.id;
          var authService = auth_service.AuthService();
          var token = await authService.login(googleusername, googlepassword);
          if (token != null) {
            Navigator.pushReplacementNamed(context, homepageroute);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wrong USERNAME OR PASSWORD')));
          }
        } else {
          email = result.email;
          displayName = result.displayName!;
          passs = result.id;
          usrname = result.email.split('@').first;
          name = result.displayName!;
          photoUrl = result.photoUrl!;
          googlesendapi(
            email,
            displayName,
            usrname,
            passs,
            photoUrl,
            googleusername,
            googlepassword,
          );
        }
      }
    } catch (error) {
      print("Error in googlesignin: $error");
    }
  }

  Future<bool> checkEmailRegistered(String email) async {
    print('check email in database');
    final String apiUrl = glb.backend + '/checkemail?email=$email';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + glb.accessToken,
      });
      print('status code is checkEmailRegistered : ${response.statusCode}');
      if (response.statusCode == 200) {
        print('status code is checkEmailRegistered sucess');
        final jsonResponse = json.decode(response.body);
        return true;
      } else {
        print(
            'SC in checkEmailRegistered async: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in checkEmailRegistered async: $e');
      return false;
    }
  }

  Future<String?> googlesendapi(
      String email,
      String displayName,
      String name,
      String id,
      String photoUrl,
      String googleUsername,
      String googlePassword) async {
    String randomDigits = (Random().nextInt(89999999) + 10000000).toString();
    String mobileNumber = '91$randomDigits';

    final String apiUrl = glb.backend + '/signup';
    final Map<String, dynamic> requestBody = {
      'email': email,
      'user_name': email.split('@').first,
      'password': id,
      'name': displayName,
      'mobile': int.parse(mobileNumber),
      'profile_photo_uri': photoUrl,
      'authorization': 'Google'
    };
    print('google signin API is $apiUrl');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      print('google signin status code is ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Signup successful : ${response.statusCode}');
        var authService = auth_service.AuthService();
        var token = await authService.login(name, id);
        if (token != null) {
          Navigator.pushReplacementNamed(context, homepageroute);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wrong USERNAME OR PASSWORD')));
        }
      } else {
        print('Signup failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return 'Process completed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 100, horizontal: 45),
          child: Form(
            key: _signInFormKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      'Hi there! Nice to see you again.',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: TextFormField(
                    controller: _usrNm_cont,
                    decoration: InputDecoration(
                      labelText: 'UserName',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'UserName is required';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: TextFormField(
                    controller: _Pswd_cont,
                    obscureText: !passwordVisible,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
                /* Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: TextFormField(
                    controller: backendUrlCont,
                    decoration: InputDecoration(
                      labelText: 'Backend url',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Backend url is required';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: TextFormField(
                    controller: jitsiUrlCont,
                    decoration: InputDecoration(
                      labelText: 'Jitsi url',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jitsi url is required';
                      }
                      return null;
                    },
                  ),
                ), */
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      if (_signInFormKey.currentState!.validate()) {
                        usrNm = _usrNm_cont.text;
                        Pswd = _Pswd_cont.text;

                        /* These are for testing, remove them in production */
                        backendUrl = backendUrlCont.text;
                        jitsiUrl = jitsiUrlCont.text;

                        if (usrNm == '111' && Pswd == '111') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => homepage()));
                        } else {
                          var authService = auth_service.AuthService();

                          /* backendUrl, jitsiUrl are for testing, remove them in production */
                          var token = await authService.login(usrNm, Pswd);

                          /* If accessToken available, navigate to homepage */
                          if (token != null) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => homepage(),
                                ),
                                (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wrong USERNAME OR PASSWORD'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1,
                        width: 80,
                        color: Colors.grey.shade300,
                      ),
                      Text(
                        ' or ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        height: 1,
                        width: 80,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    googlesignin();
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Image.asset(
                      'assets/image/google.png',
                      height: 25,
                      width: 25,
                    ),
                    title: Transform.translate(
                      offset: Offset(-16, 0),
                      child: Text('Sign in with Google'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => forgotpassword_page()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
