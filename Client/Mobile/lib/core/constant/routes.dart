class AppRoute {
  // Auth
  static const String login = "/login";
  static const String signUp = "/signup";
  static const String register = "/register";
  static const String onBoarding = "/onboarding";
  static const String forgetPassword = "/forgetpassword";
  static const String verfiyCode = "/verfiycode";
  static const String resetPassword = "/reset-password";
  static const String successSignUp = "/successsignup";
  static const String successResetpassword = "/successresetpassword";
  static const String checkemail = "/checkemail";
  static const String verfiyCodeSignUp = "/verfiycodesignup";
  static const String forgetPasswordEmail = "/forget-password-email";
  static const String forgetPasswordOTP = "/forget-password-otp";

  // Main Navigation
  static const String main = "/main";
  static const String homepage = "/main"; // Alias

  // Pages
  static const String items = "/items";
  static const String productdetails = "/productdetails";
  static const String myfavroite = "/myfavroite";
  static const String cart = "/cart";
  static const String shop = "/shop";

  // Address
  static const String addressview = "/addressview";
  static const String addressadd = "/addressadd";
  static const String checkout = "/checkout";
  static const String addressadddetails = "/addressadddetails";

  // Orders
  static const String orders = "/orders";
  static const String orderspending = "/orderspending";
  static const String ordersarchive = "/ordersarchive";
  static const String ordersdetails = "/ordersdetails";

  static const String emailVerification = "/email-verification";
  static const String otpVerification = "/otp-verification";

  // Phase 2: Rentals & Orders
  static const String myRentals = "/my-rentals";
  static const String rentalDetail = "/rental-detail";
  static const String createRental = "/create-rental";
  static const String myOrders = "/my-orders";
  static const String orderDetail = "/order-detail";

  // Phase 3: Communication & Engagement
  static const String notifications = "/notifications";
  static const String favorites = "/favorites";
  static const String chatList = "/chat-list";
  static const String chatRoom = "/chat-room";

  // Phase 5: Expert / Verification & Wallet
  static const String expertAssigned = "/expert-assigned";
  static const String verificationHistory = "/verification-history";
  static const String wallet = "/wallet";
}