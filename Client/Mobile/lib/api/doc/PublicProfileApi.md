# renty_api.api.PublicProfileApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPublicProfile**](PublicProfileApi.md#getpublicprofile) | **GET** /api/v1/public-profile/{userId} | 


# **getPublicProfile**
> ApiResponseOfPublicProfileDto getPublicProfile(userId)



### Example
```dart
import 'package:renty_api/api.dart';

final api_instance = PublicProfileApi();
final userId = 789; // int | 

try {
    final result = api_instance.getPublicProfile(userId);
    print(result);
} catch (e) {
    print('Exception when calling PublicProfileApi->getPublicProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | 

### Return type

[**ApiResponseOfPublicProfileDto**](ApiResponseOfPublicProfileDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

