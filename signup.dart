import 'dart:convert';

import 'package:debate/src/views/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:debate/src/views/utils/global.dart' as glb;
import 'package:flutter/services.dart';
import 'package:debate/src/services/auth_service.dart' as auth_service;
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _signupFormKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool? _isChecked = false;
  String? dateErrorText;
  bool isCountrySelected = false;
//bool isEmailRegistered = false;

  TextEditingController name_cont = TextEditingController();
  TextEditingController username_cont = TextEditingController();
  TextEditingController email_cont = TextEditingController();
  TextEditingController mobile_cont = TextEditingController();
  TextEditingController password_cont = TextEditingController();
  TextEditingController address_cont = TextEditingController();
  TextEditingController date_cont = TextEditingController();
  TextEditingController countryController = TextEditingController();

  String username = "";
  String email = "";
  String mobile = "";
  String password = "";
  String name = "";
  String address = "";
  String dob = "";
  String? gender;
  String selectedCountryCode = '';
  String selectedCountryName = '';

  Future<Country?> _openCountryPickerDialog() async {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
        setState(() {
          selectedCountryCode = country.phoneCode!;
          selectedCountryName = country.name!;
          isCountrySelected = true;
        });
      },
    );
  }

  Future<void> checkUsernameRegistered() async {
    print('check user_name in database');
    var user_name = username_cont.text;
    final String apiUrl = glb.backend + '/checkusername?username=$user_name';
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + glb.accessToken,
      });
      print('status code is UsernameRegistered : ${response.statusCode}');
      if (response.statusCode == 200) {
        print('status code is checkUsernameRegistered sucess');
        final jsonResponse = json.decode(response.body);
        glb.error_popup(context, 'Username already exists');
      } else if (response.statusCode == 404) {
        checkEmailRegistered();
      } else {
        print('Username is not exist');
      }
    } catch (e) {
      print('Username is not exist');
    }
  }

  Future<void> checkEmailRegistered() async {
    print('check email in database');
    var email = email_cont.text;
    final String apiUrl = glb.backend + '/checkemail?email=$email';
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + glb.accessToken,
      });
      print('status code is checkEmailRegistered : ${response.statusCode}');
      if (response.statusCode == 200) {
        print('status code is checkEmailRegistered sucess');
        final jsonResponse = json.decode(response.body);
        glb.error_popup(context, 'Email already exists');
      } else if (response.statusCode == 404) {
        String formattedMobile =
            '${countryController.text}' '${mobile_cont.text}';
        var authService = auth_service.AuthService();
        bool signupSuccess = await authService.signup(
          name,
          username,
          email,
          address,
          dob,
          gender!,
          formattedMobile,
          password,
          glb.profile_photo_uri,
        );
        if (signupSuccess) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        }
      } else {
        print('email is not exist');
      }
    } catch (e) {
      print('email is not exist');
    }
  }

  @override
  void initState() {
    super.initState();
    dateErrorText = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 01, horizontal: 45),
        child: ListView(
          children: [
            Form(
              key: _signupFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      controller: name_cont,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        if (value.contains(RegExp(r'[0-9]'))) {
                          return 'Name cannot contain numbers';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      controller: username_cont,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        // Check for the username to start with an alphabet
                        if (!RegExp(r'^[A-Za-z]').hasMatch(value)) {
                          return 'Username must start with an alphabet';
                        }
                          if (value.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }

                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      controller: email_cont,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return 'Enter a valid email!';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                        controller: address_cont,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          if (value.length < 4) {
                            return 'Address must be at least 4 characters long';
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: TextField(
                      controller: date_cont,
                      decoration: InputDecoration(
                          labelText: "Date of Birth",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                      readOnly: true,
                      onTap: () async {
                        DateTime currentDate = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100));

                        if (pickedDate != null) {
                          print(pickedDate);
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(formattedDate);
                          setState(() {
                            date_cont.text = formattedDate;
                          });
                          int age = currentDate.year - pickedDate.year;
                          if (currentDate.month < pickedDate.month ||
                              (currentDate.month == pickedDate.month &&
                                  currentDate.day < pickedDate.day)) {
                            age--;
                          }

                          if (age < 13) {
                            setState(() {
                              // Update the error message text
                              dateErrorText =
                                  'User must be at least 13 years old';
                            });
                          } else {
                            // Reset the error message text
                            setState(() {
                              dateErrorText = null;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  if (dateErrorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        dateErrorText!,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize:
                                12 // Set the color of the error message text
                            ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'Male',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                            Text('Male'),
                            Radio(
                              value: 'Female',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                            Text('Female'),
                            Radio(
                              value: 'others',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                            Text('Others'),
                          ],
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: countryController,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Country Code is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: 'Country code',
                                labelStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              showCountryPicker(
                                  context: context,
                                  onSelect: (Country country) {
                                    setState(() {
                                      selectedCountryCode = country.phoneCode;
                                      countryController.text =
                                          '+$selectedCountryCode';
                                    });
                                  });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: mobile_cont,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (value.length != 10) {
                                return 'Enter valid number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Mobile No',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 15),
                  //   child: Row(
                  //     children: [
                  //       SizedBox(width: 10,),
                  //       Expanded(
                  //         flex: 3,
                  //         child: IntlPhoneField(
                  //           controller: mobile_cont,
                  //           decoration: InputDecoration(
                  //             labelText: 'Mobile No',
                  //             labelStyle: TextStyle(
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //           initialCountryCode: 'IN', // Initial country code (you can set it to your preferred default)
                  //           onChanged: (phone) {
                  //             print(phone.completeNumber); // Updated phone number as user types
                  //           },
                  //           onCountryChanged: (phone) {
                  //           //  print(phone.countryCode); // Updated country code as user changes it
                  //           },
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: TextFormField(
                      controller: password_cont,
                      obscureText: !passwordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!RegExp(r'\d').hasMatch(value)) {
                          return 'Password must contain at least one digit';
                        }

                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Transform.translate(
                        offset: Offset(-14, 0),
                        child: Text(
                          'I agree to the Terms of Services and Privacy Policy',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      value: _isChecked,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isChecked = newValue;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50)),
                      onPressed: () async {
                        if (_signupFormKey.currentState!.validate()) {
                          name = name_cont.text;
                          username = username_cont.text;
                          email = email_cont.text;
                          address = address_cont.text;
                          dob = date_cont.text;
                          mobile = '+' +
                              selectedCountryCode +
                              ' ' +
                              mobile_cont.text;
                          password = password_cont.text;
                          // checkEmailRegistered();
                          checkUsernameRegistered();
                        }
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have an Account?',
                        style: TextStyle(fontSize: 15),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
