import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/constant/linkapi.dart';
import '../component/button.dart';
import '../component/crud.dart';
import '../component/logo.dart';
import '../component/textformfield.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';
import 'email_verification_notification.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  Crud _crud = Crud();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  signUp() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationNotification(
          email: emailController.text.isNotEmpty
              ? emailController.text
              : "test@example.com",
        ),
      ),
    );
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
                "Create Account",
                style: TextStyle(color: AppColor.primaryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Enter your information to get started",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Text("Full Name", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your full name",
                controller: nameController,
              ),
              SizedBox(height: 20),
              Text("Email", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              Text(
                "Phone Number",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your phone number",
                controller: phoneController,
                keyboardType: TextInputType.phone,
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
              SizedBox(height: 20),
              Text(
                "Confirm Password",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              CustomTextForm(
                hintText: "Confirm your password",
                controller: confirmController,
                obscureText: true,
                isPassword: true,
              ),
              SizedBox(height: 30),
              Button(
                title: "Register",
                isLoading: isLoading,
                onpressed: signUp,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Login",
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
