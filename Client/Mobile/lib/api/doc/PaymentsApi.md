# renty_api.api.PaymentsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPayment**](PaymentsApi.md#createpayment) | **POST** /api/v1/payments | 
[**getPaymentByOrder**](PaymentsApi.md#getpaymentbyorder) | **GET** /api/v1/payments/{orderId} | 


# **createPayment**
> ApiResponseOfPaymentCreateData createPayment(createPaymentCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final createPaymentCommand = CreatePaymentCommand(); // CreatePaymentCommand | 

try {
    final result = api_instance.createPayment(createPaymentCommand);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->createPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPaymentCommand** | [**CreatePaymentCommand**](CreatePaymentCommand.md)|  | 

### Return type

[**ApiResponseOfPaymentCreateData**](ApiResponseOfPaymentCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPaymentByOrder**
> ApiResponseOfPaymentDto getPaymentByOrder(orderId)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final orderId = orderId_example; // String | 

try {
    final result = api_instance.getPaymentByOrder(orderId);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->getPaymentByOrder: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **orderId** | **String**|  | 

### Return type

[**ApiResponseOfPaymentDto**](ApiResponseOfPaymentDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

