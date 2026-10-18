# renty_api.api.AdminItemsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getApprovalHistory**](AdminItemsApi.md#getapprovalhistory) | **GET** /api/v1/admin/approvals/history | 
[**getPendingItems**](AdminItemsApi.md#getpendingitems) | **GET** /api/v1/admin/items/pending | 
[**reviewItem**](AdminItemsApi.md#reviewitem) | **POST** /api/v1/admin/items/{id}/review | 


# **getApprovalHistory**
> ApiResponseOfListOfApprovalHistoryDto getApprovalHistory()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminItemsApi();

try {
    final result = api_instance.getApprovalHistory();
    print(result);
} catch (e) {
    print('Exception when calling AdminItemsApi->getApprovalHistory: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfListOfApprovalHistoryDto**](ApiResponseOfListOfApprovalHistoryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPendingItems**
> ApiResponseOfListOfItemListDto getPendingItems()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminItemsApi();

try {
    final result = api_instance.getPendingItems();
    print(result);
} catch (e) {
    print('Exception when calling AdminItemsApi->getPendingItems: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfListOfItemListDto**](ApiResponseOfListOfItemListDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reviewItem**
> ApiResponseOfObject reviewItem(id, reviewItemCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminItemsApi();
final id = id_example; // String | 
final reviewItemCommand = ReviewItemCommand(); // ReviewItemCommand | 

try {
    final result = api_instance.reviewItem(id, reviewItemCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminItemsApi->reviewItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **reviewItemCommand** | [**ReviewItemCommand**](ReviewItemCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

