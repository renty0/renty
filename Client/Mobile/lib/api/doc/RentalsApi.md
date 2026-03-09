# renty_api.api.RentalsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**activateRental**](RentalsApi.md#activaterental) | **PUT** /api/v1/rentals/{id}/activate | 
[**cancelRental**](RentalsApi.md#cancelrental) | **PUT** /api/v1/rentals/{id}/cancel | 
[**completeRental**](RentalsApi.md#completerental) | **PUT** /api/v1/rentals/{id}/complete | 
[**confirmRental**](RentalsApi.md#confirmrental) | **PUT** /api/v1/rentals/{id}/confirm | 
[**createRental**](RentalsApi.md#createrental) | **POST** /api/v1/rentals | 
[**getRentalById**](RentalsApi.md#getrentalbyid) | **GET** /api/v1/rentals/{id} | 
[**getRentals**](RentalsApi.md#getrentals) | **GET** /api/v1/rentals | 


# **activateRental**
> ApiResponseOfRentalStatusData activateRental(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final id = id_example; // String | 

try {
    final result = api_instance.activateRental(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->activateRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfRentalStatusData**](ApiResponseOfRentalStatusData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelRental**
> ApiResponseOfRentalStatusData cancelRental(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final id = id_example; // String | 

try {
    final result = api_instance.cancelRental(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->cancelRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfRentalStatusData**](ApiResponseOfRentalStatusData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeRental**
> ApiResponseOfRentalCompleteData completeRental(id, damaged)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final id = id_example; // String | 
final damaged = true; // bool | 

try {
    final result = api_instance.completeRental(id, damaged);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->completeRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **damaged** | **bool**|  | 

### Return type

[**ApiResponseOfRentalCompleteData**](ApiResponseOfRentalCompleteData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmRental**
> ApiResponseOfRentalStatusData confirmRental(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final id = id_example; // String | 

try {
    final result = api_instance.confirmRental(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->confirmRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfRentalStatusData**](ApiResponseOfRentalStatusData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRental**
> ApiResponseOfRentalCreateData createRental(createRentalCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final createRentalCommand = CreateRentalCommand(); // CreateRentalCommand | 

try {
    final result = api_instance.createRental(createRentalCommand);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->createRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRentalCommand** | [**CreateRentalCommand**](CreateRentalCommand.md)|  | 

### Return type

[**ApiResponseOfRentalCreateData**](ApiResponseOfRentalCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRentalById**
> ApiResponseOfRentalDetailDto getRentalById(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getRentalById(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->getRentalById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfRentalDetailDto**](ApiResponseOfRentalDetailDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRentals**
> ApiResponseOfGetRentalsResponse getRentals(page, limit, status)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RentalsApi();
final page = 56; // int | 
final limit = 56; // int | 
final status = status_example; // String | 

try {
    final result = api_instance.getRentals(page, limit, status);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->getRentals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **status** | **String**|  | [optional] 

### Return type

[**ApiResponseOfGetRentalsResponse**](ApiResponseOfGetRentalsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

