# renty_api.api.AdminSettingsApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAdminSettings**](AdminSettingsApi.md#getadminsettings) | **GET** /api/v1/admin/settings | 
[**updateAdminSetting**](AdminSettingsApi.md#updateadminsetting) | **POST** /api/v1/admin/settings | 


# **getAdminSettings**
> ApiResponseOfObject getAdminSettings()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminSettingsApi();

try {
    final result = api_instance.getAdminSettings();
    print(result);
} catch (e) {
    print('Exception when calling AdminSettingsApi->getAdminSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateAdminSetting**
> ApiResponseOfObject updateAdminSetting(updateSettingCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminSettingsApi();
final updateSettingCommand = UpdateSettingCommand(); // UpdateSettingCommand | 

try {
    final result = api_instance.updateAdminSetting(updateSettingCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminSettingsApi->updateAdminSetting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateSettingCommand** | [**UpdateSettingCommand**](UpdateSettingCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

