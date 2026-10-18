# renty_api.api.DeliveryApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDelivery**](DeliveryApi.md#getdelivery) | **GET** /api/v1/orders/{id}/delivery | 
[**updateDelivery**](DeliveryApi.md#updatedelivery) | **PUT** /api/v1/orders/{id}/delivery | 


# **getDelivery**
> ApiResponseOfListOfTrackingEntryDto getDelivery(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DeliveryApi();
final id = id_example; // String | 

try {
    final result = api_instance.getDelivery(id);
    print(result);
} catch (e) {
    print('Exception when calling DeliveryApi->getDelivery: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfListOfTrackingEntryDto**](ApiResponseOfListOfTrackingEntryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDelivery**
> ApiResponseOfObject updateDelivery(id, updateDeliveryCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DeliveryApi();
final id = id_example; // String | 
final updateDeliveryCommand = UpdateDeliveryCommand(); // UpdateDeliveryCommand | 

try {
    final result = api_instance.updateDelivery(id, updateDeliveryCommand);
    print(result);
} catch (e) {
    print('Exception when calling DeliveryApi->updateDelivery: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateDeliveryCommand** | [**UpdateDeliveryCommand**](UpdateDeliveryCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

