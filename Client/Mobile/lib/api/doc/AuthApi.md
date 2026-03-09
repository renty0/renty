# renty_api.api.AuthApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authForgotPassword**](AuthApi.md#authforgotpassword) | **POST** /api/v1/auth/forgot-password | 
[**authLogin**](AuthApi.md#authlogin) | **POST** /api/v1/auth/login | 
[**authMe**](AuthApi.md#authme) | **GET** /api/v1/auth/me | 
[**authRefresh**](AuthApi.md#authrefresh) | **POST** /api/v1/auth/refresh | 
[**authRegister**](AuthApi.md#authregister) | **POST** /api/v1/auth/register | 
[**authResetPassword**](AuthApi.md#authresetpassword) | **POST** /api/v1/auth/reset-password | 
[**authSendVerification**](AuthApi.md#authsendverification) | **POST** /api/v1/auth/send-verification | 
[**authUpdateMe**](AuthApi.md#authupdateme) | **PUT** /api/v1/auth/me | 
[**authVerifyEmail**](AuthApi.md#authverifyemail) | **POST** /api/v1/auth/verify-email | 
[**authVerifyResetCode**](AuthApi.md#authverifyresetcode) | **POST** /api/v1/auth/verify-reset-code | 


# **authForgotPassword**
> ApiResponseOfObject authForgotPassword(forgotPasswordCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final forgotPasswordCommand = ForgotPasswordCommand(); // ForgotPasswordCommand | 

try {
    final result = api_instance.authForgotPassword(forgotPasswordCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authForgotPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordCommand** | [**ForgotPasswordCommand**](ForgotPasswordCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogin**
> ApiResponseOfAuthLoginData authLogin(loginCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final loginCommand = LoginCommand(); // LoginCommand | 

try {
    final result = api_instance.authLogin(loginCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginCommand** | [**LoginCommand**](LoginCommand.md)|  | 

### Return type

[**ApiResponseOfAuthLoginData**](ApiResponseOfAuthLoginData.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authMe**
> ApiResponseOfAuthMeData authMe()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();

try {
    final result = api_instance.authMe();
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfAuthMeData**](ApiResponseOfAuthMeData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRefresh**
> ApiResponseOfAuthRefreshData authRefresh(refreshTokenCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final refreshTokenCommand = RefreshTokenCommand(); // RefreshTokenCommand | 

try {
    final result = api_instance.authRefresh(refreshTokenCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenCommand** | [**RefreshTokenCommand**](RefreshTokenCommand.md)|  | 

### Return type

[**ApiResponseOfAuthRefreshData**](ApiResponseOfAuthRefreshData.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegister**
> ApiResponseOfAuthRegisterData authRegister(registerCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final registerCommand = RegisterCommand(); // RegisterCommand | 

try {
    final result = api_instance.authRegister(registerCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerCommand** | [**RegisterCommand**](RegisterCommand.md)|  | 

### Return type

[**ApiResponseOfAuthRegisterData**](ApiResponseOfAuthRegisterData.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authResetPassword**
> ApiResponseOfObject authResetPassword(resetPasswordCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final resetPasswordCommand = ResetPasswordCommand(); // ResetPasswordCommand | 

try {
    final result = api_instance.authResetPassword(resetPasswordCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authResetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordCommand** | [**ResetPasswordCommand**](ResetPasswordCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authSendVerification**
> ApiResponseOfObject authSendVerification(sendEmailConfirmationCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final sendEmailConfirmationCommand = SendEmailConfirmationCommand(); // SendEmailConfirmationCommand | 

try {
    final result = api_instance.authSendVerification(sendEmailConfirmationCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authSendVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendEmailConfirmationCommand** | [**SendEmailConfirmationCommand**](SendEmailConfirmationCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authUpdateMe**
> ApiResponseOfObject authUpdateMe(updateUserCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();
final updateUserCommand = UpdateUserCommand(); // UpdateUserCommand | 

try {
    final result = api_instance.authUpdateMe(updateUserCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authUpdateMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateUserCommand** | [**UpdateUserCommand**](UpdateUserCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authVerifyEmail**
> ApiResponseOfAuthVerifyEmailData authVerifyEmail(confirmEmailCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final confirmEmailCommand = ConfirmEmailCommand(); // ConfirmEmailCommand | 

try {
    final result = api_instance.authVerifyEmail(confirmEmailCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authVerifyEmail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **confirmEmailCommand** | [**ConfirmEmailCommand**](ConfirmEmailCommand.md)|  | 

### Return type

[**ApiResponseOfAuthVerifyEmailData**](ApiResponseOfAuthVerifyEmailData.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authVerifyResetCode**
> ApiResponseOfObject authVerifyResetCode(verifyResetTokenCommand)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = AuthApi();
final verifyResetTokenCommand = VerifyResetTokenCommand(); // VerifyResetTokenCommand | 

try {
    final result = api_instance.authVerifyResetCode(verifyResetTokenCommand);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authVerifyResetCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyResetTokenCommand** | [**VerifyResetTokenCommand**](VerifyResetTokenCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

