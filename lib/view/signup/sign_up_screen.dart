import 'package:provider/provider.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/res/components/input_text_field.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/signup/signup_controller.dart';

import '../../res/color.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // Added for confirmation
  final userNameController = TextEditingController();

  final emailFocusNode = FocusNode();
  final userNameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode(); // Added for confirmation

  // String selectedRole = 'student'; // Default role is student

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(
            color: AppColors.bgColor,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            background: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Image.asset(
              'assets/images/bg.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ChangeNotifierProvider(
                  create: (_) => SignUpController(),
                  child: Consumer<SignUpController>(
                    builder: (context, provider, child) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * .01,),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: AppFonts.alatsiRegular,
                              ),
                            ),
                            SizedBox(height: height * .01,),
                            Text(
                              'Start learning\nSign Up Today!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                                fontFamily: AppFonts.alatsiRegular,
                                height: 0.95,
                              ),
                            ),
                            SizedBox(height: height * .01,),
                            Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.only(top: height * .06, bottom: height * 0.01),
                                child: Column(
                                  children: [
                                    InputTextField(
                                      myController: userNameController,
                                      focusNode: userNameFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: false,
                                      hint: 'Username',
                                      onValidator: (value) {
                                        return value.isEmpty ? 'Enter username' : null;
                                      },
                                      prefixIcon: Icon(Icons.person, color: Colors.green.withOpacity(0.8)),
                                    ),
                                    SizedBox(height: height * 0.01,),

                                    InputTextField(
                                      myController: emailController,
                                      focusNode: emailFocusNode,
                                      onFiledSubmitValue: (value) {
                                        Utils.fieldFocus(context, emailFocusNode, passwordFocusNode);
                                      },
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: false,
                                      hint: 'Email',
                                      onValidator: (value) {
                                        return value.isEmpty ? 'Enter email' : null;
                                      },
                                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple.withOpacity(0.8)),
                                    ),

                                    SizedBox(height: height * 0.01,),

                                    InputTextField(
                                      myController: passwordController,
                                      focusNode: passwordFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: true,
                                      hint: 'Password',
                                      onValidator: (value) {
                                        return value.isEmpty ? 'Enter password' : null;
                                      },
                                      prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent.withOpacity(0.8)),
                                      isPassword: true,
                                    ),

                                    SizedBox(height: height * 0.01,),

                                    InputTextField(
                                      myController: confirmPasswordController,
                                      focusNode: confirmPasswordFocusNode,
                                      onFiledSubmitValue: (value) {},
                                      keyBoardType: TextInputType.emailAddress,
                                      obscureText: true,
                                      hint: 'Confirm Password',
                                      onValidator: (value) {
                                        if (value.isEmpty) {
                                          return 'Enter password again';
                                        } else if (value != passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent.withOpacity(0.8)),
                                      isPassword: true,
                                    ),

                                    // Role selection dropdown
                                    // Align(
                                    //   alignment: Alignment.center, // Align the DropdownButton to the left
                                    //   child: DropdownButton<String>(
                                    //     value: selectedRole,
                                    //     items: [
                                    //       DropdownMenuItem(
                                    //         value: 'student',
                                    //         child: Text('Student'),
                                    //       ),
                                    //       DropdownMenuItem(
                                    //         value: 'educator',
                                    //         child: Text('Educator'),
                                    //       ),
                                    //     ],
                                    //     onChanged: (value) {
                                    //       setState(() {
                                    //         selectedRole = value!;
                                    //       });
                                    //     },
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40,),
                            RoundButton(
                              color: Colors.green.withOpacity(0.8),
                              title: 'Sign Up',
                              loading: provider.loading,
                              onPress: () {
                                if (_formKey.currentState!.validate()) {
                                  if (passwordController.text == confirmPasswordController.text) {
                                    // Passwords match, proceed with signup
                                    provider.signup(
                                      context,
                                      userNameController.text,
                                      emailController.text,
                                      passwordController.text,
                                      // selectedRole, // Pass the selected role
                                    );
                                  } else {
                                    // Passwords don't match, display an error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Passwords do not match.'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(height: height * .03,),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}