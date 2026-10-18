# renty_api.api.BrandsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createBrand**](BrandsApi.md#createbrand) | **POST** /api/v1/brands | 
[**deleteBrand**](BrandsApi.md#deletebrand) | **DELETE** /api/v1/brands/{id} | 
[**getBrandById**](BrandsApi.md#getbrandbyid) | **GET** /api/v1/brands/{id} | 
[**getBrands**](BrandsApi.md#getbrands) | **GET** /api/v1/brands | 
[**updateBrand**](BrandsApi.md#updatebrand) | **PUT** /api/v1/brands/{id} | 


# **createBrand**
> ApiResponseOfBrandDto createBrand(createBrandCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BrandsApi();
final createBrandCommand = CreateBrandCommand(); // CreateBrandCommand | 

try {
    final result = api_instance.createBrand(createBrandCommand);
    print(result);
} catch (e) {
    print('Exception when calling BrandsApi->createBrand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBrandCommand** | [**CreateBrandCommand**](CreateBrandCommand.md)|  | 

### Return type

[**ApiResponseOfBrandDto**](ApiResponseOfBrandDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBrand**
> ApiResponseOfObject deleteBrand(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BrandsApi();
final id = 56; // int | 

try {
    final result = api_instance.deleteBrand(id);
    print(result);
} catch (e) {
    print('Exception when calling BrandsApi->deleteBrand: $e\n');
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

# **getBrandById**
> ApiResponseOfBrandDto getBrandById(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = BrandsApi();
final id = 56; // int | 

try {
    final result = api_instance.getBrandById(id);
    print(result);
} catch (e) {
    print('Exception when calling BrandsApi->getBrandById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfBrandDto**](ApiResponseOfBrandDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBrands**
> ApiResponseOfListOfBrandDto getBrands(page, limit, search, sortBy, sortOrder)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = BrandsApi();
final page = 56; // int | 
final limit = 56; // int | 
final search = search_example; // String | 
final sortBy = sortBy_example; // String | 
final sortOrder = sortOrder_example; // String | 

try {
    final result = api_instance.getBrands(page, limit, search, sortBy, sortOrder);
    print(result);
} catch (e) {
    print('Exception when calling BrandsApi->getBrands: $e\n');
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

[**ApiResponseOfListOfBrandDto**](ApiResponseOfListOfBrandDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateBrand**
> ApiResponseOfBrandDto updateBrand(id, updateBrandCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BrandsApi();
final id = 56; // int | 
final updateBrandCommand = UpdateBrandCommand(); // UpdateBrandCommand | 

try {
    final result = api_instance.updateBrand(id, updateBrandCommand);
    print(result);
} catch (e) {
    print('Exception when calling BrandsApi->updateBrand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateBrandCommand** | [**UpdateBrandCommand**](UpdateBrandCommand.md)|  | 

### Return type

[**ApiResponseOfBrandDto**](ApiResponseOfBrandDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

