# renty_api.api.SupportApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSupportTicket**](SupportApi.md#createsupportticket) | **POST** /api/v1/support/tickets | 
[**getSupportTickets**](SupportApi.md#getsupporttickets) | **GET** /api/v1/support/tickets | 
[**postSupportMessage**](SupportApi.md#postsupportmessage) | **POST** /api/v1/support/tickets/{id}/messages | 
[**updateSupportTicketStatus**](SupportApi.md#updatesupportticketstatus) | **PUT** /api/v1/support/tickets/{id}/status | 


# **createSupportTicket**
> ApiResponseOfSupportCreateTicketData createSupportTicket(createTicketCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SupportApi();
final createTicketCommand = CreateTicketCommand(); // CreateTicketCommand | 

try {
    final result = api_instance.createSupportTicket(createTicketCommand);
    print(result);
} catch (e) {
    print('Exception when calling SupportApi->createSupportTicket: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createTicketCommand** | [**CreateTicketCommand**](CreateTicketCommand.md)|  | 

### Return type

[**ApiResponseOfSupportCreateTicketData**](ApiResponseOfSupportCreateTicketData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSupportTickets**
> ApiResponseOfGetTicketsResponse getSupportTickets()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SupportApi();

try {
    final result = api_instance.getSupportTickets();
    print(result);
} catch (e) {
    print('Exception when calling SupportApi->getSupportTickets: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfGetTicketsResponse**](ApiResponseOfGetTicketsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postSupportMessage**
> ApiResponseOfSupportMessageData postSupportMessage(id, postSupportMessageCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SupportApi();
final id = id_example; // String | 
final postSupportMessageCommand = PostSupportMessageCommand(); // PostSupportMessageCommand | 

try {
    final result = api_instance.postSupportMessage(id, postSupportMessageCommand);
    print(result);
} catch (e) {
    print('Exception when calling SupportApi->postSupportMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **postSupportMessageCommand** | [**PostSupportMessageCommand**](PostSupportMessageCommand.md)|  | 

### Return type

[**ApiResponseOfSupportMessageData**](ApiResponseOfSupportMessageData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSupportTicketStatus**
> ApiResponseOfSupportTicketStatusData updateSupportTicketStatus(id, updateTicketStatusCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SupportApi();
final id = id_example; // String | 
final updateTicketStatusCommand = UpdateTicketStatusCommand(); // UpdateTicketStatusCommand | 

try {
    final result = api_instance.updateSupportTicketStatus(id, updateTicketStatusCommand);
    print(result);
} catch (e) {
    print('Exception when calling SupportApi->updateSupportTicketStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateTicketStatusCommand** | [**UpdateTicketStatusCommand**](UpdateTicketStatusCommand.md)|  | 

### Return type

[**ApiResponseOfSupportTicketStatusData**](ApiResponseOfSupportTicketStatusData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

