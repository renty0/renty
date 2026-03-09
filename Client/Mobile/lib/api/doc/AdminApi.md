# renty_api.api.AdminApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAdminGapAnalysis**](AdminApi.md#getadmingapanalysis) | **GET** /api/v1/admin/gap | 
[**getAdminKpis**](AdminApi.md#getadminkpis) | **GET** /api/v1/admin/kpis | 
[**getAdminLatestKpi**](AdminApi.md#getadminlatestkpi) | **GET** /api/v1/admin/kpis/latest | 
[**getAdminUsers**](AdminApi.md#getadminusers) | **GET** /api/v1/admin/users | 
[**getFraudLogs**](AdminApi.md#getfraudlogs) | **GET** /api/v1/admin/fraud | 
[**updateUserStatus**](AdminApi.md#updateuserstatus) | **PUT** /api/v1/admin/users/{id}/status | 


# **getAdminGapAnalysis**
> ApiResponseOfObject getAdminGapAnalysis(limit, period)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final limit = 56; // int | 
final period = period_example; // String | 

try {
    final result = api_instance.getAdminGapAnalysis(limit, period);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminGapAnalysis: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | 
 **period** | **String**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminKpis**
> ApiResponseOfObject getAdminKpis(period, from, to)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final period = period_example; // String | 
final from = 2013-10-20T19:20:30+01:00; // DateTime | 
final to = 2013-10-20T19:20:30+01:00; // DateTime | 

try {
    final result = api_instance.getAdminKpis(period, from, to);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminKpis: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminLatestKpi**
> ApiResponseOfObject getAdminLatestKpi()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();

try {
    final result = api_instance.getAdminLatestKpi();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminLatestKpi: $e\n');
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

# **getAdminUsers**
> ApiResponseOfObject getAdminUsers(page, limit)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final page = 56; // int | 
final limit = 56; // int | 

try {
    final result = api_instance.getAdminUsers(page, limit);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminUsers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFraudLogs**
> ApiResponseOfObject getFraudLogs(page, limit, decision, minRisk)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final page = 56; // int | 
final limit = 56; // int | 
final decision = decision_example; // String | 
final minRisk = 1.2; // double | 

try {
    final result = api_instance.getFraudLogs(page, limit, decision, minRisk);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getFraudLogs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | 
 **limit** | **int**|  | 
 **decision** | **String**|  | [optional] 
 **minRisk** | **double**|  | [optional] 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserStatus**
> ApiResponseOfObject updateUserStatus(id, updateUserStatusCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 789; // int | 
final updateUserStatusCommand = UpdateUserStatusCommand(); // UpdateUserStatusCommand | 

try {
    final result = api_instance.updateUserStatus(id, updateUserStatusCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->updateUserStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateUserStatusCommand** | [**UpdateUserStatusCommand**](UpdateUserStatusCommand.md)|  | 

### Return type

[**ApiResponseOfObject**](ApiResponseOfObject.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

