import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:over_taxi_driver/constant/styleText.dart';
import 'package:over_taxi_driver/widget/loginButton.dart';

import 'Home.dart';

//Declaring a StatefulWidget

//Now the Signin Class is StatefulWidget with an initialized State
class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  var emailctrl = TextEditingController();

  var passwordctrl = TextEditingController();

  bool ispass = true;

  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context)
        .size; //Getting the Screen Size despite the device type
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      //SingleChildScollView in order to avoid error when the keyboard shows.
      body: SingleChildScrollView(
        child: Container(
          width: size
              .width, //Declaring that the container width is as much as the screen.
          color: Colors.white,
          child: Column(
            children: [
              Image.asset('img/logoscreen.png'), //Adding the OVER image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 39.1),
                  child: Text(
                    '',
                    style: kstartText,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 46.0),
                      child: Text(
                        'مرحبا, سُعدنا بعملك معنا ',
                        style: kWelcomeLogin,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 53.0, bottom: 27),
                      child: Text(
                        'تسجيل دخول السائق',
                        style: kNavigateLogin,
                      ),
                    ),
                    Form(
                      key: formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          //Modified way usingthe 'inputText' Function with the following parameters:
                          // Size : passing the Size of the screen (Height, Width, etc..).
                          // Label: The labelText that will show.
                          // ctrl : The Controller that will be passed.
                          // keyboardtype: The Type of the allowed keyboard to be used.
                          // validator: Validation Function for each one depending on the conditions of each field.
                          inputText(
                            size: size,
                            label: 'الإيميل',
                            ctrl: emailctrl,
                            keyboardtype: TextInputType.text,
                            validator: validateEmail,
                          ),
                          inputText(
                            size: size,
                            label: 'كلمة المرور',
                            ctrl: passwordctrl,
                            keyboardtype: TextInputType.visiblePassword,
                            validator: (val) => val!.length == 0
                                ? 'Please Enter Your Password'
                                : null,
                            icon: Icons.lock,
                            ispassword: ispass,
                            suffixIcon: ispass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            suffixPressed: () {
                              setState(() {
                                ispass = !ispass;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    //TextInputField for Inserting the Number.
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //login button
              LoginButton(
                //A Button will show the Text ارسال كود and when Pressed will lead to Verification screen.
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    Get.offAll(Home());
                  }
                },
                text: 'تسجيل الدخول',
              ),
              // enter visitor
            ],
          ),
        ),
      ),
    );
  }

  Widget inputText({
    //All Required so it must be passed.
    @required Size? size,
    @required String? label,
    @required TextEditingController? ctrl,
    @required TextInputType? keyboardtype,
    @required String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    //Optional input validator (Used for Age).
    IconData? icon,
    IconData? suffixIcon,
    bool ispassword = false,
    VoidCallback? suffixPressed,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 10),
      margin:
          EdgeInsetsDirectional.only(end: 25, start: 25, top: 12, bottom: 12),
      width: size!.width,
      height: 65,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ]),
      child: TextFormField(
        inputFormatters: inputFormatters,
        keyboardType: keyboardtype,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon != null
              ? IconButton(icon: Icon(suffixIcon), onPressed: suffixPressed)
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: -1),
          labelText: label,
          labelStyle: TextStyle(fontSize: 20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        obscureText: ispassword,
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value!.length == 0)
      return 'Please enter your Email';
    else if (!EmailValidator.validate(value))
      return 'Please enter a valid Email';
    else
      return null;
  }
}
