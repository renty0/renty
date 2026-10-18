# renty_api.api.IdentityApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**confirmPhoneVerification**](IdentityApi.md#confirmphoneverification) | **POST** /api/v1/user/phone/confirm | 
[**getIdVerificationRequests**](IdentityApi.md#getidverificationrequests) | **GET** /api/v1/admin/id-verifications | 
[**requestPhoneVerification**](IdentityApi.md#requestphoneverification) | **POST** /api/v1/user/phone/request | 
[**reviewIdVerification**](IdentityApi.md#reviewidverification) | **POST** /api/v1/admin/id-verifications/{id}/review | 
[**uploadIdVerification**](IdentityApi.md#uploadidverification) | **POST** /api/v1/user/id/upload | 


# **confirmPhoneVerification**
> ApiResponseOfObject confirmPhoneVerification(confirmPhoneVerificationCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IdentityApi();
final confirmPhoneVerificationCommand = ConfirmPhoneVerificationCommand(); // ConfirmPhoneVerificationCommand | 

try {
    final result = api_instance.confirmPhoneVerification(confirmPhoneVerificationCommand);
    print(result);
} catch (e) {
    print('Exception when calling IdentityApi->confirmPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **confirmPhoneVerificationCommand** | [**ConfirmPhoneVerificationCommand**](ConfirmPhoneVerificationCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getIdVerificationRequests**
> ApiResponseOfGetIdVerificationRequestsResponse getIdVerificationRequests(page, limit, status, sortOrder)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IdentityApi();
final page = 56; // int | 
final limit = 56; // int | 
final status = status_example; // String | 
final sortOrder = sortOrder_example; // String | 

try {
    final result = api_instance.getIdVerificationRequests(page, limit, status, sortOrder);
    print(result);
} catch (e) {
    print('Exception when calling IdentityApi->getIdVerificationRequests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] 
 **limit** | **int**|  | [optional] 
 **status** | **String**|  | [optional] 
 **sortOrder** | **String**|  | [optional] 

### Return type

[**ApiResponseOfGetIdVerificationRequestsResponse**](ApiResponseOfGetIdVerificationRequestsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestPhoneVerification**
> ApiResponseOfObject requestPhoneVerification(requestPhoneVerificationCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IdentityApi();
final requestPhoneVerificationCommand = RequestPhoneVerificationCommand(); // RequestPhoneVerificationCommand | 

try {
    final result = api_instance.requestPhoneVerification(requestPhoneVerificationCommand);
    print(result);
} catch (e) {
    print('Exception when calling IdentityApi->requestPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestPhoneVerificationCommand** | [**RequestPhoneVerificationCommand**](RequestPhoneVerificationCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewIdVerification**
> ApiResponseOfObject reviewIdVerification(id, reviewIdVerificationCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IdentityApi();
final id = id_example; // String | 
final reviewIdVerificationCommand = ReviewIdVerificationCommand(); // ReviewIdVerificationCommand | 

try {
    final result = api_instance.reviewIdVerification(id, reviewIdVerificationCommand);
    print(result);
} catch (e) {
    print('Exception when calling IdentityApi->reviewIdVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **reviewIdVerificationCommand** | [**ReviewIdVerificationCommand**](ReviewIdVerificationCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadIdVerification**
> ApiResponseOfObject uploadIdVerification(uploadIdVerificationCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IdentityApi();
final uploadIdVerificationCommand = UploadIdVerificationCommand(); // UploadIdVerificationCommand | 

try {
    final result = api_instance.uploadIdVerification(uploadIdVerificationCommand);
    print(result);
} catch (e) {
    print('Exception when calling IdentityApi->uploadIdVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **uploadIdVerificationCommand** | [**UploadIdVerificationCommand**](UploadIdVerificationCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

