import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/constant/linkapi.dart';
import 'package:renty/main.dart';
import 'package:renty/component/crud.dart';
import 'package:renty/component/logo.dart';
import 'package:renty/component/button.dart';
import 'package:renty/component/textformfield.dart';
import 'package:renty/utils/language_manager.dart';
import 'package:renty/utils/theme_manager.dart';
import 'package:renty/utils/favorites_manager.dart';
import 'package:renty/core/functions/checkinternet.dart';
import 'package:renty/core/middleware/internet_middleware.dart';
import 'forget_password_email.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool isLoading = false;
  Crud crud = Crud();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  signIn() async {
    Navigator.of(context).pushNamedAndRemoveUntil("/main", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 30),
              Logo(),
              SizedBox(height: 30),
              Text(
                "Welcome Back",
                style: TextStyle(color: AppColor.primaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Login to continue",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Text("Email", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              Text("Password", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your password",
                controller: passController,
                obscureText: true,
                isPassword: true,
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ForgetPasswordEmailPage(),
                    ),
                  );
                },
                child: Container(
                  alignment: TextDirection.ltr == Directionality.of(context)
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Button(title: "Login", isLoading: isLoading, onpressed: signIn),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed("/register");
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
