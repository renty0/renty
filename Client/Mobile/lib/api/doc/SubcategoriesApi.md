# renty_api.api.SubcategoriesApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSubcategory**](SubcategoriesApi.md#createsubcategory) | **POST** /api/v1/subcategories | 
[**deleteSubcategory**](SubcategoriesApi.md#deletesubcategory) | **DELETE** /api/v1/subcategories/{id} | 
[**getSubcategories**](SubcategoriesApi.md#getsubcategories) | **GET** /api/v1/subcategories | 
[**getSubcategoriesByCategory**](SubcategoriesApi.md#getsubcategoriesbycategory) | **GET** /api/v1/categories/{categoryId}/subcategories | 
[**getSubcategoryById**](SubcategoriesApi.md#getsubcategorybyid) | **GET** /api/v1/subcategories/{id} | 
[**updateSubcategory**](SubcategoriesApi.md#updatesubcategory) | **PUT** /api/v1/subcategories/{id} | 


# **createSubcategory**
> ApiResponseOfProductSubcategoryDto createSubcategory(createSubcategoryCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SubcategoriesApi();
final createSubcategoryCommand = CreateSubcategoryCommand(); // CreateSubcategoryCommand | 

try {
    final result = api_instance.createSubcategory(createSubcategoryCommand);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->createSubcategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSubcategoryCommand** | [**CreateSubcategoryCommand**](CreateSubcategoryCommand.md)|  | 

### Return type

[**ApiResponseOfProductSubcategoryDto**](ApiResponseOfProductSubcategoryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSubcategory**
> ApiResponseOfObject deleteSubcategory(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SubcategoriesApi();
final id = 56; // int | 

try {
    final result = api_instance.deleteSubcategory(id);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->deleteSubcategory: $e\n');
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

# **getSubcategories**
> ApiResponseOfListOfProductSubcategoryDto getSubcategories(page, limit, categoryId, search, sortBy, sortOrder)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = SubcategoriesApi();
final page = 56; // int | 
final limit = 56; // int | 
final categoryId = 56; // int | 
final search = search_example; // String | 
final sortBy = sortBy_example; // String | 
final sortOrder = sortOrder_example; // String | 

try {
    final result = api_instance.getSubcategories(page, limit, categoryId, search, sortBy, sortOrder);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->getSubcategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **categoryId** | **int**|  | [optional] 
 **search** | **String**|  | [optional] 
 **sortBy** | **String**|  | [optional] 
 **sortOrder** | **String**|  | [optional] 

### Return type

[**ApiResponseOfListOfProductSubcategoryDto**](ApiResponseOfListOfProductSubcategoryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSubcategoriesByCategory**
> ApiResponseOfListOfProductSubcategoryDto getSubcategoriesByCategory(categoryId, page, limit, sortBy, sortOrder)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = SubcategoriesApi();
final categoryId = 56; // int | 
final page = 56; // int | 
final limit = 56; // int | 
final sortBy = sortBy_example; // String | 
final sortOrder = sortOrder_example; // String | 

try {
    final result = api_instance.getSubcategoriesByCategory(categoryId, page, limit, sortBy, sortOrder);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->getSubcategoriesByCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryId** | **int**|  | 
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **sortBy** | **String**|  | [optional] 
 **sortOrder** | **String**|  | [optional] 

### Return type

[**ApiResponseOfListOfProductSubcategoryDto**](ApiResponseOfListOfProductSubcategoryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSubcategoryById**
> ApiResponseOfProductSubcategoryDto getSubcategoryById(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = SubcategoriesApi();
final id = 56; // int | 

try {
    final result = api_instance.getSubcategoryById(id);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->getSubcategoryById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfProductSubcategoryDto**](ApiResponseOfProductSubcategoryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSubcategory**
> ApiResponseOfProductSubcategoryDto updateSubcategory(id, updateSubcategoryCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SubcategoriesApi();
final id = 56; // int | 
final updateSubcategoryCommand = UpdateSubcategoryCommand(); // UpdateSubcategoryCommand | 

try {
    final result = api_instance.updateSubcategory(id, updateSubcategoryCommand);
    print(result);
} catch (e) {
    print('Exception when calling SubcategoriesApi->updateSubcategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateSubcategoryCommand** | [**UpdateSubcategoryCommand**](UpdateSubcategoryCommand.md)|  | 

### Return type

[**ApiResponseOfProductSubcategoryDto**](ApiResponseOfProductSubcategoryDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

