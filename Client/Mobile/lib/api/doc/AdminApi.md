# renty_api.api.AdminApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *https://starfish-app-vavqt.ondigitalocean.app*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assignUserRoles**](AdminApi.md#assignuserroles) | **PUT** /api/v1/admin/users/{id}/roles | 
[**createAdminUser**](AdminApi.md#createadminuser) | **POST** /api/v1/admin/users | 
[**createRole**](AdminApi.md#createrole) | **POST** /api/v1/admin/roles | 
[**deleteRole**](AdminApi.md#deleterole) | **DELETE** /api/v1/admin/roles/{id} | 
[**getAdminGapAnalysis**](AdminApi.md#getadmingapanalysis) | **GET** /api/v1/admin/gap | 
[**getAdminKpis**](AdminApi.md#getadminkpis) | **GET** /api/v1/admin/kpis | 
[**getAdminLatestKpi**](AdminApi.md#getadminlatestkpi) | **GET** /api/v1/admin/kpis/latest | 
[**getAdminRentalFinancials**](AdminApi.md#getadminrentalfinancials) | **GET** /api/v1/admin/rentals/{id}/financials | 
[**getAdminRoles**](AdminApi.md#getadminroles) | **GET** /api/v1/admin/roles | 
[**getAdminUsers**](AdminApi.md#getadminusers) | **GET** /api/v1/admin/users | 
[**getAvailablePermissions**](AdminApi.md#getavailablepermissions) | **GET** /api/v1/admin/permissions | 
[**getFraudLogs**](AdminApi.md#getfraudlogs) | **GET** /api/v1/admin/fraud | 
[**getRoleDetails**](AdminApi.md#getroledetails) | **GET** /api/v1/admin/roles/{id} | 
[**updateRole**](AdminApi.md#updaterole) | **PUT** /api/v1/admin/roles/{id} | 
[**updateUserStatus**](AdminApi.md#updateuserstatus) | **PUT** /api/v1/admin/users/{id}/status | 


# **assignUserRoles**
> ApiResponseOfResult assignUserRoles(id, assignUserRolesCommand)



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
final assignUserRolesCommand = AssignUserRolesCommand(); // AssignUserRolesCommand | 

try {
    final result = api_instance.assignUserRoles(id, assignUserRolesCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->assignUserRoles: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **assignUserRolesCommand** | [**AssignUserRolesCommand**](AssignUserRolesCommand.md)|  | 

### Return type

[**ApiResponseOfResult**](ApiResponseOfResult.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAdminUser**
> ApiResponseOfCreateAdminUserResponse createAdminUser(createAdminUserCommand)



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
final createAdminUserCommand = CreateAdminUserCommand(); // CreateAdminUserCommand | 

try {
    final result = api_instance.createAdminUser(createAdminUserCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->createAdminUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAdminUserCommand** | [**CreateAdminUserCommand**](CreateAdminUserCommand.md)|  | 

### Return type

[**ApiResponseOfCreateAdminUserResponse**](ApiResponseOfCreateAdminUserResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRole**
> ApiResponseOfResult createRole(createRoleCommand)



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
final createRoleCommand = CreateRoleCommand(); // CreateRoleCommand | 

try {
    final result = api_instance.createRole(createRoleCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->createRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRoleCommand** | [**CreateRoleCommand**](CreateRoleCommand.md)|  | 

### Return type

[**ApiResponseOfResult**](ApiResponseOfResult.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRole**
> ApiResponseOfResult deleteRole(id)



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

try {
    final result = api_instance.deleteRole(id);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->deleteRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfResult**](ApiResponseOfResult.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminGapAnalysis**
> ApiResponseOfGetGapAnalysisResponse getAdminGapAnalysis(limit, period)



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

[**ApiResponseOfGetGapAnalysisResponse**](ApiResponseOfGetGapAnalysisResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminKpis**
> ApiResponseOfGetKpisResponse getAdminKpis(period, from, to)



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

[**ApiResponseOfGetKpisResponse**](ApiResponseOfGetKpisResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminLatestKpi**
> ApiResponseOfKpiSnapshotDto getAdminLatestKpi()



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

[**ApiResponseOfKpiSnapshotDto**](ApiResponseOfKpiSnapshotDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminRentalFinancials**
> ApiResponseOfRentalFinancialBreakdownDto getAdminRentalFinancials(id)



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
final id = id_example; // String | 

try {
    final result = api_instance.getAdminRentalFinancials(id);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminRentalFinancials: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfRentalFinancialBreakdownDto**](ApiResponseOfRentalFinancialBreakdownDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminRoles**
> ApiResponseOfListOfRoleDto getAdminRoles()



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
    final result = api_instance.getAdminRoles();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAdminRoles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfListOfRoleDto**](ApiResponseOfListOfRoleDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminUsers**
> ApiResponseOfGetAdminUsersResponse getAdminUsers(page, limit, searchTerm)



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
final searchTerm = searchTerm_example; // String | 

try {
    final result = api_instance.getAdminUsers(page, limit, searchTerm);
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
 **searchTerm** | **String**|  | [optional] 

### Return type

[**ApiResponseOfGetAdminUsersResponse**](ApiResponseOfGetAdminUsersResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAvailablePermissions**
> ApiResponseOfListOfPermissionMetadataDto getAvailablePermissions()



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
    final result = api_instance.getAvailablePermissions();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAvailablePermissions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfListOfPermissionMetadataDto**](ApiResponseOfListOfPermissionMetadataDto.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFraudLogs**
> ApiResponseOfGetFraudLogsResponse getFraudLogs(page, limit, decision, minRisk)



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

[**ApiResponseOfGetFraudLogsResponse**](ApiResponseOfGetFraudLogsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRoleDetails**
> ApiResponseOfRoleDetailsResponse getRoleDetails(id)



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

try {
    final result = api_instance.getRoleDetails(id);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getRoleDetails: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseOfRoleDetailsResponse**](ApiResponseOfRoleDetailsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRole**
> ApiResponseOfResult updateRole(id, updateRoleCommand)



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
final updateRoleCommand = UpdateRoleCommand(); // UpdateRoleCommand | 

try {
    final result = api_instance.updateRole(id, updateRoleCommand);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->updateRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateRoleCommand** | [**UpdateRoleCommand**](UpdateRoleCommand.md)|  | 

### Return type

[**ApiResponseOfResult**](ApiResponseOfResult.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUserStatus**
> ApiResponseOfUpdateUserStatusResponse updateUserStatus(id, updateUserStatusCommand)



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

[**ApiResponseOfUpdateUserStatusResponse**](ApiResponseOfUpdateUserStatusResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

