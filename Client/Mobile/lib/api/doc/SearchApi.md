# renty_api.api.SearchApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**searchItems**](SearchApi.md#searchitems) | **GET** /api/v1/search | 


# **searchItems**
> ApiResponseOfSearchItemsResponse searchItems(q, page, limit, categoryId, city)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = SearchApi();
final q = q_example; // String | 
final page = 56; // int | 
final limit = 56; // int | 
final categoryId = 56; // int | 
final city = city_example; // String | 

try {
    final result = api_instance.searchItems(q, page, limit, categoryId, city);
    print(result);
} catch (e) {
    print('Exception when calling SearchApi->searchItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **categoryId** | **int**|  | [optional] 
 **city** | **String**|  | [optional] 

### Return type

[**ApiResponseOfSearchItemsResponse**](ApiResponseOfSearchItemsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

