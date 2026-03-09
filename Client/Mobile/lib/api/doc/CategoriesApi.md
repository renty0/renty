# renty_api.api.CategoriesApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createCategory**](CategoriesApi.md#createcategory) | **POST** /api/v1/categories | 
[**deleteCategory**](CategoriesApi.md#deletecategory) | **DELETE** /api/v1/categories/{id} | 
[**getCategories**](CategoriesApi.md#getcategories) | **GET** /api/v1/categories | 
[**getCategoryById**](CategoriesApi.md#getcategorybyid) | **GET** /api/v1/categories/{id} | 
[**updateCategory**](CategoriesApi.md#updatecategory) | **PUT** /api/v1/categories/{id} | 


# **createCategory**
> ApiResponseOfProductCategoryDto createCategory(createCategoryCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CategoriesApi();
final createCategoryCommand = CreateCategoryCommand(); // CreateCategoryCommand | 

try {
    final result = api_instance.createCategory(createCategoryCommand);
    print(result);
} catch (e) {
    print('Exception when calling CategoriesApi->createCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCategoryCommand** | [**CreateCategoryCommand**](CreateCategoryCommand.md)|  | 

### Return type

[**ApiResponseOfProductCategoryDto**](ApiResponseOfProductCategoryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCategory**
> ApiResponseOfObject deleteCategory(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CategoriesApi();
final id = 56; // int | 

try {
    final result = api_instance.deleteCategory(id);
    print(result);
} catch (e) {
    print('Exception when calling CategoriesApi->deleteCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCategories**
> ApiResponseOfListOfProductCategoryDto getCategories(page, limit, search, sortBy, sortOrder)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = CategoriesApi();
final page = 56; // int | 
final limit = 56; // int | 
final search = search_example; // String | 
final sortBy = sortBy_example; // String | 
final sortOrder = sortOrder_example; // String | 

try {
    final result = api_instance.getCategories(page, limit, search, sortBy, sortOrder);
    print(result);
} catch (e) {
    print('Exception when calling CategoriesApi->getCategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **search** | **String**|  | [optional] 
 **sortBy** | **String**|  | [optional] 
 **sortOrder** | **String**|  | [optional] 

### Return type

[**ApiResponseOfListOfProductCategoryDto**](ApiResponseOfListOfProductCategoryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCategoryById**
> ApiResponseOfProductCategoryDto getCategoryById(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = CategoriesApi();
final id = 56; // int | 

try {
    final result = api_instance.getCategoryById(id);
    print(result);
} catch (e) {
    print('Exception when calling CategoriesApi->getCategoryById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfProductCategoryDto**](ApiResponseOfProductCategoryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCategory**
> ApiResponseOfProductCategoryDto updateCategory(id, updateCategoryCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CategoriesApi();
final id = 56; // int | 
final updateCategoryCommand = UpdateCategoryCommand(); // UpdateCategoryCommand | 

try {
    final result = api_instance.updateCategory(id, updateCategoryCommand);
    print(result);
} catch (e) {
    print('Exception when calling CategoriesApi->updateCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateCategoryCommand** | [**UpdateCategoryCommand**](UpdateCategoryCommand.md)|  | 

### Return type

[**ApiResponseOfProductCategoryDto**](ApiResponseOfProductCategoryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

