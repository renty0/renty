# renty_api.api.RentalsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelExpertReview**](RentalsApi.md#cancelexpertreview) | **DELETE** /api/v1/rentals/{id}/request-expert | 
[**cancelRental**](RentalsApi.md#cancelrental) | **PUT** /api/v1/rentals/{id}/cancel | 
[**completeRental**](RentalsApi.md#completerental) | **PUT** /api/v1/rentals/{id}/complete | 
[**confirmRental**](RentalsApi.md#confirmrental) | **PUT** /api/v1/rentals/{id}/confirm | 
[**createRental**](RentalsApi.md#createrental) | **POST** /api/v1/rentals | 
[**deleteRentalPhoto**](RentalsApi.md#deleterentalphoto) | **DELETE** /api/v1/rentals/{id}/photos | 
[**generateExpertToOwnerTransfers**](RentalsApi.md#generateexperttoownertransfers) | **POST** /api/v1/rentals/{id}/transfers/expert-return | 
[**generateHandoffFromHubTransfers**](RentalsApi.md#generatehandofffromhubtransfers) | **POST** /api/v1/rentals/{id}/transfers/handoff-from-hub | 
[**generateTransfers**](RentalsApi.md#generatetransfers) | **POST** /api/v1/rentals/{id}/transfers/generate | 
[**getRentalById**](RentalsApi.md#getrentalbyid) | **GET** /api/v1/rentals/{id} | 
[**getRentals**](RentalsApi.md#getrentals) | **GET** /api/v1/rentals | 
[**openRentalDispute**](RentalsApi.md#openrentaldispute) | **POST** /api/v1/rentals/{id}/dispute | 
[**requestExpertReview**](RentalsApi.md#requestexpertreview) | **PUT** /api/v1/rentals/{id}/request-expert | 
[**requestRentalExtension**](RentalsApi.md#requestrentalextension) | **POST** /api/v1/rentals/{id}/extend | 
[**respondToExtension**](RentalsApi.md#respondtoextension) | **PUT** /api/v1/rentals/{id}/extend/{extId}/respond | 
[**setHandoffMethod**](RentalsApi.md#sethandoffmethod) | **PUT** /api/v1/rentals/{id}/handoff | 
[**updatePossession**](RentalsApi.md#updatepossession) | **PUT** /api/v1/rentals/{id}/possession | 
[**uploadRentalPhotos**](RentalsApi.md#uploadrentalphotos) | **POST** /api/v1/rentals/{id}/photos | 
[**verifyTransfer**](RentalsApi.md#verifytransfer) | **PUT** /api/v1/rentals/{id}/verify-transfer | 


# **cancelExpertReview**
> ApiResponseOfObject cancelExpertReview(id)



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
    final result = api_instance.cancelExpertReview(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->cancelExpertReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

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
> ApiResponseOfRentalCreateData createRental(createRentalRequest)



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
final createRentalRequest = CreateRentalRequest(); // CreateRentalRequest | 

try {
    final result = api_instance.createRental(createRentalRequest);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->createRental: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRentalRequest** | [**CreateRentalRequest**](CreateRentalRequest.md)|  | 

### Return type

[**ApiResponseOfRentalCreateData**](ApiResponseOfRentalCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRentalPhoto**
> ApiResponseOfObject deleteRentalPhoto(id, imageUrl)



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
final imageUrl = imageUrl_example; // String | 

try {
    final result = api_instance.deleteRentalPhoto(id, imageUrl);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->deleteRentalPhoto: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **imageUrl** | **String**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateExpertToOwnerTransfers**
> ApiResponseOfObject generateExpertToOwnerTransfers(id, method)



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
final method = method_example; // String | 

try {
    final result = api_instance.generateExpertToOwnerTransfers(id, method);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->generateExpertToOwnerTransfers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **method** | **String**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateHandoffFromHubTransfers**
> ApiResponseOfObject generateHandoffFromHubTransfers(id, method)



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
final method = method_example; // String | 

try {
    final result = api_instance.generateHandoffFromHubTransfers(id, method);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->generateHandoffFromHubTransfers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **method** | **String**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateTransfers**
> ApiResponseOfObject generateTransfers(id, method)



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
final method = method_example; // String | 

try {
    final result = api_instance.generateTransfers(id, method);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->generateTransfers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **method** | **String**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
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
> ApiResponseOfGetRentalsResponse getRentals(page, limit, status, role)



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
final role = role_example; // String | 

try {
    final result = api_instance.getRentals(page, limit, status, role);
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
 **role** | **String**|  | [optional] 

### Return type

[**ApiResponseOfGetRentalsResponse**](ApiResponseOfGetRentalsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **openRentalDispute**
> ApiResponseOfObject openRentalDispute(id, openDisputeBody)



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
final openDisputeBody = OpenDisputeBody(); // OpenDisputeBody | 

try {
    final result = api_instance.openRentalDispute(id, openDisputeBody);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->openRentalDispute: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **openDisputeBody** | [**OpenDisputeBody**](OpenDisputeBody.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestExpertReview**
> ApiResponseOfObject requestExpertReview(id)



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
    final result = api_instance.requestExpertReview(id);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->requestExpertReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestRentalExtension**
> ApiResponseOfObject requestRentalExtension(id, extendRentalBody)



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
final extendRentalBody = ExtendRentalBody(); // ExtendRentalBody | 

try {
    final result = api_instance.requestRentalExtension(id, extendRentalBody);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->requestRentalExtension: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **extendRentalBody** | [**ExtendRentalBody**](ExtendRentalBody.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **respondToExtension**
> ApiResponseOfObject respondToExtension(id, extId, respondExtensionBody)



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
final extId = extId_example; // String | 
final respondExtensionBody = RespondExtensionBody(); // RespondExtensionBody | 

try {
    final result = api_instance.respondToExtension(id, extId, respondExtensionBody);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->respondToExtension: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **extId** | **String**|  | 
 **respondExtensionBody** | [**RespondExtensionBody**](RespondExtensionBody.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setHandoffMethod**
> ApiResponseOfRentalStatusData setHandoffMethod(id, setHandoffMethodBody)



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
final setHandoffMethodBody = SetHandoffMethodBody(); // SetHandoffMethodBody | 

try {
    final result = api_instance.setHandoffMethod(id, setHandoffMethodBody);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->setHandoffMethod: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **setHandoffMethodBody** | [**SetHandoffMethodBody**](SetHandoffMethodBody.md)|  | 

### Return type

[**ApiResponseOfRentalStatusData**](ApiResponseOfRentalStatusData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePossession**
> ApiResponseOfObject updatePossession(id, action, method)



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
final action = action_example; // String | 
final method = method_example; // String | 

try {
    final result = api_instance.updatePossession(id, action, method);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->updatePossession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **action** | **String**|  | 
 **method** | **String**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadRentalPhotos**
> ApiResponseOfObject uploadRentalPhotos(id, uploadRentalPhotosBody)



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
final uploadRentalPhotosBody = UploadRentalPhotosBody(); // UploadRentalPhotosBody | 

try {
    final result = api_instance.uploadRentalPhotos(id, uploadRentalPhotosBody);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->uploadRentalPhotos: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **uploadRentalPhotosBody** | [**UploadRentalPhotosBody**](UploadRentalPhotosBody.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyTransfer**
> ApiResponseOfObject verifyTransfer(id, body)



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
final body = String(); // String | 

try {
    final result = api_instance.verifyTransfer(id, body);
    print(result);
} catch (e) {
    print('Exception when calling RentalsApi->verifyTransfer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **body** | **String**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

