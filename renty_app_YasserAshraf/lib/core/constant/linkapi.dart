class AppLink {
  // Base Server URL
  static const String server = "https://appforyou.store/backendnaseej";
  static const String imageBase = "$server/upload";

  // Image Directories
  static const String productsImages = "$imageBase/products";
  static const String categoriesImages = "$imageBase/categories";
  static const String profilesImages = "$imageBase/profiles";
  static const String storesImages = "$imageBase/stores";

  // ================================= User Authentication ========================== //
  static const String signUp = "$server/user_auth/signup.php";
  static const String verifyEmail = "$server/user_auth/verify_email.php";
  static const String resendOTP = "$server/user_auth/resend_otp.php";
  static const String login = "$server/user_auth/login.php";
  static const String logout = "$server/user_auth/logout.php";
  static const String validateSession = "$server/user_auth/validate_session.php";

  // ================================= Forget Password ========================== //
  static const String forgotPassword = "$server/user_auth/forgot_password.php";
  static const String verifyResetOTP = "$server/user_auth/verify_reset_otp.php";
  static const String resetPassword = "$server/user_auth/reset_password.php";

  // ================================= User Profile ========================== //
  static const String getProfile = "$server/user_profile/get_profile.php";
  static const String updateProfile = "$server/user_profile/update_profile.php";
  static const String changePassword = "$server/user_profile/change_password.php";
  static const String uploadProfileImage = "$server/user_profile/upload_profile_image.php";
  static const String deleteProfileImage = "$server/user_profile/delete_profile_image.php";
  static const String deleteAccount = "$server/user_profile/delete_account.php";

  // ================================= User Shop/Products (NEW) ========================== //
  static const String homeProducts = "$server/user_shop/get_home_products.php";
  static const String allProducts = "$server/user_shop/get_all_products.php";
  static const String productDetails = "$server/user_shop/get_product_details.php";
  static const String activeCategories = "$server/user_shop/get_active_categories.php";
  static const String specialOffers = "$server/user_shop/get_special_offers.php";
  static const String freeShippingProducts = "$server/user_shop/get_free_shipping.php";
  static const String newArrivals = "$server/user_shop/get_new_arrivals.php";
  static const String searchProducts = "$server/user_shop/search_products.php";

  // ================================= OLD Shop APIs (Keep for backward compatibility) ========================== //
  static const String categories = "$server/shop/get_categories.php";
  static const String products = "$server/shop/get_products.php";
  static const String recommendedProducts = "$server/shop/get_recommended_products.php";
  static const String discountedProducts = "$server/shop/get_discounted_products.php";

  // ================================= Favorites ========================== //
  static const String getFavorites = "$server/favorites/get_favorites.php";
  static const String addFavorite = "$server/favorites/add_favorite.php";
  static const String removeFavorite = "$server/favorites/remove_favorite.php";
  static const String checkFavorite = "$server/favorites/check_favorite.php";

  // ================================= Cart ========================== //
  static const String getCart = "$server/cart/get_cart.php";
  static const String addToCart = "$server/cart/add_to_cart.php";
  static const String updateCartItem = "$server/cart/update_cart_item.php";
  static const String removeFromCart = "$server/cart/remove_from_cart.php";
  static const String clearCart = "$server/cart/clear_cart.php";
  // ================================= Orders ========================== //
  static const String createOrder = "$server/user_orders/create_order.php";
  static const String getOrders = "$server/user_orders/get_orders.php";
  static const String getOrderDetails = "$server/user_orders/get_order_details.php";
  static const String cancelOrder = "$server/user_orders/cancel_order.php";
  static const String trackOrder = "$server/user_orders/track_order.php";
  // ================================= Stores ========================== //
  static const String getStores = "$server/user_stores/get_stores.php";
  static const String getStoreDetails = "$server/user_stores/get_store_details.php";
  static const String searchStores = "$server/user_stores/search_stores.php";

  // ================================= Addresses ========================== //
  static const String getAddresses = "$server/addresses/get_addresses.php";
  static const String addAddress = "$server/addresses/add_address.php";
  static const String updateAddress = "$server/addresses/update_address.php";
  static const String deleteAddress = "$server/addresses/delete_address.php";
  static const String setDefaultAddress = "$server/addresses/set_default_address.php";

  // ================================= Payment Methods ========================== //
  static const String getPaymentMethods = "$server/payment_methods/get_payment_methods.php";
  static const String addPaymentMethod = "$server/payment_methods/add_payment_method.php";
  static const String updatePaymentMethod = "$server/payment_methods/update_payment_method.php";
  static const String deletePaymentMethod = "$server/payment_methods/delete_payment_method.php";
  static const String setDefaultPaymentMethod = "$server/payment_methods/default_payment_method.php";



}