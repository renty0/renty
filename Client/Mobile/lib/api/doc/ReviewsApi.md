# renty_api.api.ReviewsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createReview**](ReviewsApi.md#createreview) | **POST** /api/v1/rentals/{id}/review | 
[**getItemReviews**](ReviewsApi.md#getitemreviews) | **GET** /api/v1/items/{id}/reviews | 


# **createReview**
> ApiResponseOfReviewCreateData createReview(id, createReviewCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReviewsApi();
final id = id_example; // String | 
final createReviewCommand = CreateReviewCommand(); // CreateReviewCommand | 

try {
    final result = api_instance.createReview(id, createReviewCommand);
    print(result);
} catch (e) {
    print('Exception when calling ReviewsApi->createReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **createReviewCommand** | [**CreateReviewCommand**](CreateReviewCommand.md)|  | 

### Return type

[**ApiResponseOfReviewCreateData**](ApiResponseOfReviewCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItemReviews**
> ApiResponseOfGetItemReviewsResponse getItemReviews(id)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = ReviewsApi();
final id = id_example; // String | 

try {
    final result = api_instance.getItemReviews(id);
    print(result);
} catch (e) {
    print('Exception when calling ReviewsApi->getItemReviews: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfGetItemReviewsResponse**](ApiResponseOfGetItemReviewsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

