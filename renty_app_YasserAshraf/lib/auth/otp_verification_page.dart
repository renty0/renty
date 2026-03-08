import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/constant/linkapi.dart';
import 'package:renty/component/button.dart';
import 'package:renty/component/crud.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final Crud _crud = Crud();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _canResend = true;
          } else {
            _startCountdown();
          }
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            "Please enter the complete 6-digit code",
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
      return;
    }

    // UI test mode: accept any 6-digit code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Email verified successfully!"),
        backgroundColor: AppColor.successColor,
      ),
    );

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    });
  }

  Future<void> _resendOTP() async {
    // CHECK INTERNET
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isResending = true;
    });

    var response = await _crud.postRequest(AppLink.resendOTP, {
      "email": widget.email,
      "type": "signup",
    });

    setState(() {
      _isResending = false;
    });

    if (response["status"] == "success") {
      // Reset countdown
      setState(() {
        _canResend = false;
        _resendCountdown = 60;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification code resent successfully!"),
          backgroundColor: AppColor.successColor,
        ),
      );
    } else {
      String errorMessage = response["message"] ?? "Failed to resend code";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.backgroundcolor2,
          content: Text(
            errorMessage,
            style: TextStyle(color: AppColor.warningColor),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColor.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),

                SizedBox(height: 20),

                // Title
                Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),

                SizedBox(height: 8),

                // Description
                Text(
                  "We've sent a 6-digit code to",
                  style: TextStyle(fontSize: 16, color: AppColor.grey),
                ),

                SizedBox(height: 4),

                // Email
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryColor,
                  ),
                ),

                SizedBox(height: 40),

                // OTP Input Field
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: isDark ? Color(0xFF2C2520) : Colors.white,
                    activeColor: AppColor.primaryColor,
                    selectedColor: AppColor.secondColor,
                    selectedFillColor: isDark
                        ? Color(0xFF2C2520)
                        : Colors.white,
                    inactiveColor: AppColor.borderGray,
                    inactiveFillColor: isDark
                        ? Color(0xFF2C2520)
                        : Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onCompleted: (v) {
                    _verifyOTP();
                  },
                  onChanged: (value) {},
                ),

                SizedBox(height: 30),

                // Verify Button
                Button(
                  title: "Verify",
                  isLoading: _isLoading,
                  onpressed: _verifyOTP,
                ),

                SizedBox(height: 40),

                // Resend Code Section
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: TextStyle(fontSize: 14, color: AppColor.grey),
                      ),

                      SizedBox(height: 8),

                      if (_canResend)
                        TextButton(
                          onPressed: _isResending ? null : _resendOTP,
                          child: _isResending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColor.primaryColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Resend Code",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                        )
                      else
                        Text(
                          "Resend code in $_resendCountdown seconds",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 100
                      : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
