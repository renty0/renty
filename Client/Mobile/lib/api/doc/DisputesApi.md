# renty_api.api.DisputesApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**resolveDispute**](DisputesApi.md#resolvedispute) | **POST** /api/v1/support/disputes/resolve | 


# **resolveDispute**
> ApiResponseOfObject resolveDispute(resolveDisputeCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DisputesApi();
final resolveDisputeCommand = ResolveDisputeCommand(); // ResolveDisputeCommand | 

try {
    final result = api_instance.resolveDispute(resolveDisputeCommand);
    print(result);
} catch (e) {
    print('Exception when calling DisputesApi->resolveDispute: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resolveDisputeCommand** | [**ResolveDisputeCommand**](ResolveDisputeCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

