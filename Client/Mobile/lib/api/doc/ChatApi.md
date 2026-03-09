# renty_api.api.ChatApi

## Load the API package
```dart
import 'package:renty_api/api.dart';
```

All URIs are relative to *http://localhost:5106*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createChat**](ChatApi.md#createchat) | **POST** /api/v1/chats | 
[**getChatMessages**](ChatApi.md#getchatmessages) | **GET** /api/v1/chats/{id}/messages | 
[**getChats**](ChatApi.md#getchats) | **GET** /api/v1/chats | 
[**postChatMessage**](ChatApi.md#postchatmessage) | **POST** /api/v1/chats/{id}/messages | 


# **createChat**
> ApiResponseOfChatCreateData createChat(createChatCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ChatApi();
final createChatCommand = CreateChatCommand(); // CreateChatCommand | 

try {
    final result = api_instance.createChat(createChatCommand);
    print(result);
} catch (e) {
    print('Exception when calling ChatApi->createChat: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createChatCommand** | [**CreateChatCommand**](CreateChatCommand.md)|  | 

### Return type

[**ApiResponseOfChatCreateData**](ApiResponseOfChatCreateData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatMessages**
> ApiResponseOfGetChatMessagesResponse getChatMessages(id)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ChatApi();
final id = id_example; // String | 

try {
    final result = api_instance.getChatMessages(id);
    print(result);
} catch (e) {
    print('Exception when calling ChatApi->getChatMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ApiResponseOfGetChatMessagesResponse**](ApiResponseOfGetChatMessagesResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChats**
> ApiResponseOfGetChatsResponse getChats()



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ChatApi();

try {
    final result = api_instance.getChats();
    print(result);
} catch (e) {
    print('Exception when calling ChatApi->getChats: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseOfGetChatsResponse**](ApiResponseOfGetChatsResponse.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postChatMessage**
> ApiResponseOfChatMessageData postChatMessage(id, postChatMessageCommand)



### Example
```dart
import 'package:renty_api/api.dart';
// TODO Configure HTTP Bearer authorization: JWT
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('JWT').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ChatApi();
final id = id_example; // String | 
final postChatMessageCommand = PostChatMessageCommand(); // PostChatMessageCommand | 

try {
    final result = api_instance.postChatMessage(id, postChatMessageCommand);
    print(result);
} catch (e) {
    print('Exception when calling ChatApi->postChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **postChatMessageCommand** | [**PostChatMessageCommand**](PostChatMessageCommand.md)|  | 

### Return type

[**ApiResponseOfChatMessageData**](ApiResponseOfChatMessageData.md)

### Authorization

[JWT](../README.md#JWT)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

