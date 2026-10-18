# renty_api.api.MediaApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**uploadMedia**](MediaApi.md#uploadmedia) | **POST** /api/v1/media | 


# **uploadMedia**
> ApiResponseOfMediaUploadData uploadMedia(entityId, entityType, file)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MediaApi();
final entityId = entityId_example; // String | 
final entityType = entityType_example; // String | 
final file = BINARY_DATA_HERE; // MultipartFile | 

try {
    final result = api_instance.uploadMedia(entityId, entityType, file);
    print(result);
} catch (e) {
    print('Exception when calling MediaApi->uploadMedia: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entityId** | **String**|  | [optional] 
 **entityType** | **String**|  | [optional] 
 **file** | **MultipartFile**|  | [optional] 

### Return type

[**ApiResponseOfMediaUploadData**](ApiResponseOfMediaUploadData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

