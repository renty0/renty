# renty_api.api.VerificationsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createVerification**](VerificationsApi.md#createverification) | **POST** /api/v1/items/{id}/verify | 
[**getExpertAssigned**](VerificationsApi.md#getexpertassigned) | **GET** /api/v1/expert/assigned | 
[**getVerifications**](VerificationsApi.md#getverifications) | **GET** /api/v1/items/{id}/verifications | 


# **createVerification**
> ApiResponseOfVerificationCreateData createVerification(id, createVerificationCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VerificationsApi();
final id = id_example; // String | 
final createVerificationCommand = CreateVerificationCommand(); // CreateVerificationCommand | 

try {
    final result = api_instance.createVerification(id, createVerificationCommand);
    print(result);
} catch (e) {
    print('Exception when calling VerificationsApi->createVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **createVerificationCommand** | [**CreateVerificationCommand**](CreateVerificationCommand.md)|  | 

### Return type

[**ApiResponseOfVerificationCreateData**](ApiResponseOfVerificationCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExpertAssigned**
> ApiResponseOfGetExpertAssignedResponse getExpertAssigned()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VerificationsApi();

try {
    final result = api_instance.getExpertAssigned();
    print(result);
} catch (e) {
    print('Exception when calling VerificationsApi->getExpertAssigned: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfGetExpertAssignedResponse**](ApiResponseOfGetExpertAssignedResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVerifications**
> ApiResponseOfGetVerificationsResponse getVerifications(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VerificationsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getVerifications(id);
    print(result);
} catch (e) {
    print('Exception when calling VerificationsApi->getVerifications: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfGetVerificationsResponse**](ApiResponseOfGetVerificationsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

