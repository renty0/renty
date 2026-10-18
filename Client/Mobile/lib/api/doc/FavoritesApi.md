# renty_api.api.FavoritesApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addFavorite**](FavoritesApi.md#addfavorite) | **POST** /api/v1/items/{id}/favorite | 
[**getMyFavorites**](FavoritesApi.md#getmyfavorites) | **GET** /api/v1/users/me/favorites | 
[**removeFavorite**](FavoritesApi.md#removefavorite) | **DELETE** /api/v1/items/{id}/favorite | 


# **addFavorite**
> ApiResponseOfObject addFavorite(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FavoritesApi();
final id = id_example; // String | 

try {
    final result = api_instance.addFavorite(id);
    print(result);
} catch (e) {
    print('Exception when calling FavoritesApi->addFavorite: $e\n');
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

# **getMyFavorites**
> ApiResponseOfGetMyFavoritesResponse getMyFavorites()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FavoritesApi();

try {
    final result = api_instance.getMyFavorites();
    print(result);
} catch (e) {
    print('Exception when calling FavoritesApi->getMyFavorites: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfGetMyFavoritesResponse**](ApiResponseOfGetMyFavoritesResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeFavorite**
> ApiResponseOfObject removeFavorite(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FavoritesApi();
final id = id_example; // String | 

try {
    final result = api_instance.removeFavorite(id);
    print(result);
} catch (e) {
    print('Exception when calling FavoritesApi->removeFavorite: $e\n');
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

