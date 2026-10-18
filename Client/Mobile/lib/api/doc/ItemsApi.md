# renty_api.api.ItemsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addItemReminder**](ItemsApi.md#additemreminder) | **POST** /api/v1/items/{id}/remind | 
[**createItem**](ItemsApi.md#createitem) | **POST** /api/v1/items | 
[**deleteItem**](ItemsApi.md#deleteitem) | **DELETE** /api/v1/items/{id} | 
[**getItemAvailability**](ItemsApi.md#getitemavailability) | **GET** /api/v1/items/{id}/availability | 
[**getItemById**](ItemsApi.md#getitembyid) | **GET** /api/v1/items/{id} | 
[**getItemReminderStatus**](ItemsApi.md#getitemreminderstatus) | **GET** /api/v1/items/{id}/remind | 
[**getItems**](ItemsApi.md#getitems) | **GET** /api/v1/items | 
[**reactivateItem**](ItemsApi.md#reactivateitem) | **POST** /api/v1/items/{id}/reactivate | 
[**removeItemReminder**](ItemsApi.md#removeitemreminder) | **DELETE** /api/v1/items/{id}/remind | 
[**updateItem**](ItemsApi.md#updateitem) | **PUT** /api/v1/items/{id} | 


# **addItemReminder**
> ApiResponseOfReminderResponse addItemReminder(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.addItemReminder(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->addItemReminder: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfReminderResponse**](ApiResponseOfReminderResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createItem**
> ApiResponseOfItemCreateData createItem(createItemCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final createItemCommand = CreateItemCommand(); // CreateItemCommand | 

try {
    final result = api_instance.createItem(createItemCommand);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->createItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createItemCommand** | [**CreateItemCommand**](CreateItemCommand.md)|  | 

### Return type

[**ApiResponseOfItemCreateData**](ApiResponseOfItemCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteItem**
> ApiResponseOfObject deleteItem(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.deleteItem(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->deleteItem: $e\n');
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

# **getItemAvailability**
> ApiResponseOfListOfBookedRangeDto getItemAvailability(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getItemAvailability(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->getItemAvailability: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfListOfBookedRangeDto**](ApiResponseOfListOfBookedRangeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItemById**
> ApiResponseOfItemDetailDto getItemById(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getItemById(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->getItemById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfItemDetailDto**](ApiResponseOfItemDetailDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItemReminderStatus**
> ApiResponseOfReminderStatusResponse getItemReminderStatus(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getItemReminderStatus(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->getItemReminderStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfReminderStatusResponse**](ApiResponseOfReminderStatusResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItems**
> ApiResponseOfListOfItemListDto getItems(page, limit, categoryId, subcategoryId, city, minPrice, maxPrice, startDate, endDate, minRating, type, condition, sort, sortOrder, owner)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = ItemsApi();
final page = 56; // int | 
final limit = 56; // int | 
final categoryId = 56; // int | 
final subcategoryId = 56; // int | 
final city = city_example; // String | 
final minPrice = 8.14; // num | 
final maxPrice = 8.14; // num | 
final startDate = 2013-10-20T19:20:30+01:00; // DateTime | 
final endDate = 2013-10-20T19:20:30+01:00; // DateTime | 
final minRating = 56; // int | 
final type = type_example; // String | 
final condition = condition_example; // String | 
final sort = sort_example; // String | 
final sortOrder = sortOrder_example; // String | 
final owner = owner_example; // String | 

try {
    final result = api_instance.getItems(page, limit, categoryId, subcategoryId, city, minPrice, maxPrice, startDate, endDate, minRating, type, condition, sort, sortOrder, owner);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->getItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **categoryId** | **int**|  | [optional] 
 **subcategoryId** | **int**|  | [optional] 
 **city** | **String**|  | [optional] 
 **minPrice** | **num**|  | [optional] 
 **maxPrice** | **num**|  | [optional] 
 **startDate** | **DateTime**|  | [optional] 
 **endDate** | **DateTime**|  | [optional] 
 **minRating** | **int**|  | [optional] 
 **type** | **String**|  | [optional] 
 **condition** | **String**|  | [optional] 
 **sort** | **String**|  | [optional] 
 **sortOrder** | **String**|  | [optional] 
 **owner** | **String**|  | [optional] 

### Return type

[**ApiResponseOfListOfItemListDto**](ApiResponseOfListOfItemListDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reactivateItem**
> ApiResponseOfObject reactivateItem(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.reactivateItem(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->reactivateItem: $e\n');
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

# **removeItemReminder**
> ApiResponseOfReminderResponse removeItemReminder(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 

try {
    final result = api_instance.removeItemReminder(id);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->removeItemReminder: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfReminderResponse**](ApiResponseOfReminderResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateItem**
> ApiResponseOfItemDetailDto updateItem(id, updateItemCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ItemsApi();
final id = id_example; // String | 
final updateItemCommand = UpdateItemCommand(); // UpdateItemCommand | 

try {
    final result = api_instance.updateItem(id, updateItemCommand);
    print(result);
} catch (e) {
    print('Exception when calling ItemsApi->updateItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateItemCommand** | [**UpdateItemCommand**](UpdateItemCommand.md)|  | 

### Return type

[**ApiResponseOfItemDetailDto**](ApiResponseOfItemDetailDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

