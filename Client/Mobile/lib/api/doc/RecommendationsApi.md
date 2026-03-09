# renty_api.api.RecommendationsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRecommendationsV1**](RecommendationsApi.md#getrecommendationsv1) | **GET** /api/v1/recommendations | 
[**recordRecommendationClick**](RecommendationsApi.md#recordrecommendationclick) | **PUT** /api/v1/recommendations/{id}/click | 


# **getRecommendationsV1**
> ApiResponseOfGetRecommendationsResponse getRecommendationsV1()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RecommendationsApi();

try {
    final result = api_instance.getRecommendationsV1();
    print(result);
} catch (e) {
    print('Exception when calling RecommendationsApi->getRecommendationsV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfGetRecommendationsResponse**](ApiResponseOfGetRecommendationsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordRecommendationClick**
> ApiResponseOfObject recordRecommendationClick(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RecommendationsApi();
final id = id_example; // String | 

try {
    final result = api_instance.recordRecommendationClick(id);
    print(result);
} catch (e) {
    print('Exception when calling RecommendationsApi->recordRecommendationClick: $e\n');
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

