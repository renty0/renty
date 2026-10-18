//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiClient {
  ApiClient({this.basePath = 'https://starfish-app-vavqt.ondigitalocean.app', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType,
  ) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = StreamedRequest(method, uri);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = MultipartRequest(method, uri);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      switch(method) {
        case 'POST': return await _client.post(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PUT': return await _client.put(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'DELETE': return await _client.delete(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PATCH': return await _client.patch(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'HEAD': return await _client.head(uri, headers: nullableHeaderParams,);
        case 'GET': return await _client.get(uri, headers: nullableHeaderParams,);
      }
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }

    throw ApiException(
      HttpStatus.badRequest,
      'Invalid HTTP operation: $method $path',
    );
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'AdminUserDto':
          return AdminUserDto.fromJson(value);
        case 'ApiResponseOfAuthLoginData':
          return ApiResponseOfAuthLoginData.fromJson(value);
        case 'ApiResponseOfAuthLoginDataData':
          return ApiResponseOfAuthLoginDataData.fromJson(value);
        case 'ApiResponseOfAuthMeData':
          return ApiResponseOfAuthMeData.fromJson(value);
        case 'ApiResponseOfAuthMeDataData':
          return ApiResponseOfAuthMeDataData.fromJson(value);
        case 'ApiResponseOfAuthRefreshData':
          return ApiResponseOfAuthRefreshData.fromJson(value);
        case 'ApiResponseOfAuthRefreshDataData':
          return ApiResponseOfAuthRefreshDataData.fromJson(value);
        case 'ApiResponseOfAuthRegisterData':
          return ApiResponseOfAuthRegisterData.fromJson(value);
        case 'ApiResponseOfAuthRegisterDataData':
          return ApiResponseOfAuthRegisterDataData.fromJson(value);
        case 'ApiResponseOfAuthVerifyEmailData':
          return ApiResponseOfAuthVerifyEmailData.fromJson(value);
        case 'ApiResponseOfAuthVerifyEmailDataData':
          return ApiResponseOfAuthVerifyEmailDataData.fromJson(value);
        case 'ApiResponseOfBrandDto':
          return ApiResponseOfBrandDto.fromJson(value);
        case 'ApiResponseOfBrandDtoData':
          return ApiResponseOfBrandDtoData.fromJson(value);
        case 'ApiResponseOfCreateAdminUserResponse':
          return ApiResponseOfCreateAdminUserResponse.fromJson(value);
        case 'ApiResponseOfCreateAdminUserResponseData':
          return ApiResponseOfCreateAdminUserResponseData.fromJson(value);
        case 'ApiResponseOfCreateChatResponse':
          return ApiResponseOfCreateChatResponse.fromJson(value);
        case 'ApiResponseOfCreateChatResponseData':
          return ApiResponseOfCreateChatResponseData.fromJson(value);
        case 'ApiResponseOfDeleteUserResponse':
          return ApiResponseOfDeleteUserResponse.fromJson(value);
        case 'ApiResponseOfDeleteUserResponseData':
          return ApiResponseOfDeleteUserResponseData.fromJson(value);
        case 'ApiResponseOfGetAdminUsersResponse':
          return ApiResponseOfGetAdminUsersResponse.fromJson(value);
        case 'ApiResponseOfGetAdminUsersResponseData':
          return ApiResponseOfGetAdminUsersResponseData.fromJson(value);
        case 'ApiResponseOfGetChatMessagesResponse':
          return ApiResponseOfGetChatMessagesResponse.fromJson(value);
        case 'ApiResponseOfGetChatMessagesResponseData':
          return ApiResponseOfGetChatMessagesResponseData.fromJson(value);
        case 'ApiResponseOfGetChatsResponse':
          return ApiResponseOfGetChatsResponse.fromJson(value);
        case 'ApiResponseOfGetChatsResponseData':
          return ApiResponseOfGetChatsResponseData.fromJson(value);
        case 'ApiResponseOfGetExpertAssignedResponse':
          return ApiResponseOfGetExpertAssignedResponse.fromJson(value);
        case 'ApiResponseOfGetExpertAssignedResponseData':
          return ApiResponseOfGetExpertAssignedResponseData.fromJson(value);
        case 'ApiResponseOfGetFraudLogsResponse':
          return ApiResponseOfGetFraudLogsResponse.fromJson(value);
        case 'ApiResponseOfGetFraudLogsResponseData':
          return ApiResponseOfGetFraudLogsResponseData.fromJson(value);
        case 'ApiResponseOfGetGapAnalysisResponse':
          return ApiResponseOfGetGapAnalysisResponse.fromJson(value);
        case 'ApiResponseOfGetGapAnalysisResponseData':
          return ApiResponseOfGetGapAnalysisResponseData.fromJson(value);
        case 'ApiResponseOfGetIdVerificationRequestsResponse':
          return ApiResponseOfGetIdVerificationRequestsResponse.fromJson(value);
        case 'ApiResponseOfGetIdVerificationRequestsResponseData':
          return ApiResponseOfGetIdVerificationRequestsResponseData.fromJson(value);
        case 'ApiResponseOfGetItemReviewsResponse':
          return ApiResponseOfGetItemReviewsResponse.fromJson(value);
        case 'ApiResponseOfGetItemReviewsResponseData':
          return ApiResponseOfGetItemReviewsResponseData.fromJson(value);
        case 'ApiResponseOfGetKpisResponse':
          return ApiResponseOfGetKpisResponse.fromJson(value);
        case 'ApiResponseOfGetKpisResponseData':
          return ApiResponseOfGetKpisResponseData.fromJson(value);
        case 'ApiResponseOfGetMyFavoritesResponse':
          return ApiResponseOfGetMyFavoritesResponse.fromJson(value);
        case 'ApiResponseOfGetMyFavoritesResponseData':
          return ApiResponseOfGetMyFavoritesResponseData.fromJson(value);
        case 'ApiResponseOfGetNotificationsResponse':
          return ApiResponseOfGetNotificationsResponse.fromJson(value);
        case 'ApiResponseOfGetNotificationsResponseData':
          return ApiResponseOfGetNotificationsResponseData.fromJson(value);
        case 'ApiResponseOfGetOrdersResponse':
          return ApiResponseOfGetOrdersResponse.fromJson(value);
        case 'ApiResponseOfGetOrdersResponseData':
          return ApiResponseOfGetOrdersResponseData.fromJson(value);
        case 'ApiResponseOfGetRecommendationsResponse':
          return ApiResponseOfGetRecommendationsResponse.fromJson(value);
        case 'ApiResponseOfGetRecommendationsResponseData':
          return ApiResponseOfGetRecommendationsResponseData.fromJson(value);
        case 'ApiResponseOfGetRentalsResponse':
          return ApiResponseOfGetRentalsResponse.fromJson(value);
        case 'ApiResponseOfGetRentalsResponseData':
          return ApiResponseOfGetRentalsResponseData.fromJson(value);
        case 'ApiResponseOfGetTicketResponse':
          return ApiResponseOfGetTicketResponse.fromJson(value);
        case 'ApiResponseOfGetTicketResponseData':
          return ApiResponseOfGetTicketResponseData.fromJson(value);
        case 'ApiResponseOfGetTicketsResponse':
          return ApiResponseOfGetTicketsResponse.fromJson(value);
        case 'ApiResponseOfGetTicketsResponseData':
          return ApiResponseOfGetTicketsResponseData.fromJson(value);
        case 'ApiResponseOfGetVerificationsResponse':
          return ApiResponseOfGetVerificationsResponse.fromJson(value);
        case 'ApiResponseOfGetVerificationsResponseData':
          return ApiResponseOfGetVerificationsResponseData.fromJson(value);
        case 'ApiResponseOfItemCreateData':
          return ApiResponseOfItemCreateData.fromJson(value);
        case 'ApiResponseOfItemCreateDataData':
          return ApiResponseOfItemCreateDataData.fromJson(value);
        case 'ApiResponseOfItemDetailDto':
          return ApiResponseOfItemDetailDto.fromJson(value);
        case 'ApiResponseOfItemDetailDtoData':
          return ApiResponseOfItemDetailDtoData.fromJson(value);
        case 'ApiResponseOfKpiSnapshotDto':
          return ApiResponseOfKpiSnapshotDto.fromJson(value);
        case 'ApiResponseOfKpiSnapshotDtoData':
          return ApiResponseOfKpiSnapshotDtoData.fromJson(value);
        case 'ApiResponseOfListOfApprovalHistoryDto':
          return ApiResponseOfListOfApprovalHistoryDto.fromJson(value);
        case 'ApiResponseOfListOfBookedRangeDto':
          return ApiResponseOfListOfBookedRangeDto.fromJson(value);
        case 'ApiResponseOfListOfBrandDto':
          return ApiResponseOfListOfBrandDto.fromJson(value);
        case 'ApiResponseOfListOfItemListDto':
          return ApiResponseOfListOfItemListDto.fromJson(value);
        case 'ApiResponseOfListOfPermissionMetadataDto':
          return ApiResponseOfListOfPermissionMetadataDto.fromJson(value);
        case 'ApiResponseOfListOfProductCategoryDto':
          return ApiResponseOfListOfProductCategoryDto.fromJson(value);
        case 'ApiResponseOfListOfProductSubcategoryDto':
          return ApiResponseOfListOfProductSubcategoryDto.fromJson(value);
        case 'ApiResponseOfListOfRoleDto':
          return ApiResponseOfListOfRoleDto.fromJson(value);
        case 'ApiResponseOfListOfTrackingEntryDto':
          return ApiResponseOfListOfTrackingEntryDto.fromJson(value);
        case 'ApiResponseOfMediaUploadData':
          return ApiResponseOfMediaUploadData.fromJson(value);
        case 'ApiResponseOfMediaUploadDataData':
          return ApiResponseOfMediaUploadDataData.fromJson(value);
        case 'ApiResponseOfNotificationMarkAllData':
          return ApiResponseOfNotificationMarkAllData.fromJson(value);
        case 'ApiResponseOfNotificationMarkAllDataData':
          return ApiResponseOfNotificationMarkAllDataData.fromJson(value);
        case 'ApiResponseOfObject':
          return ApiResponseOfObject.fromJson(value);
        case 'ApiResponseOfOrderCreateData':
          return ApiResponseOfOrderCreateData.fromJson(value);
        case 'ApiResponseOfOrderCreateDataData':
          return ApiResponseOfOrderCreateDataData.fromJson(value);
        case 'ApiResponseOfOrderDetailDto':
          return ApiResponseOfOrderDetailDto.fromJson(value);
        case 'ApiResponseOfOrderDetailDtoData':
          return ApiResponseOfOrderDetailDtoData.fromJson(value);
        case 'ApiResponseOfPaymentCreateData':
          return ApiResponseOfPaymentCreateData.fromJson(value);
        case 'ApiResponseOfPaymentCreateDataData':
          return ApiResponseOfPaymentCreateDataData.fromJson(value);
        case 'ApiResponseOfPaymentDto':
          return ApiResponseOfPaymentDto.fromJson(value);
        case 'ApiResponseOfPaymentDtoData':
          return ApiResponseOfPaymentDtoData.fromJson(value);
        case 'ApiResponseOfPostChatMessageResponse':
          return ApiResponseOfPostChatMessageResponse.fromJson(value);
        case 'ApiResponseOfPostChatMessageResponseData':
          return ApiResponseOfPostChatMessageResponseData.fromJson(value);
        case 'ApiResponseOfProductCategoryDto':
          return ApiResponseOfProductCategoryDto.fromJson(value);
        case 'ApiResponseOfProductCategoryDtoData':
          return ApiResponseOfProductCategoryDtoData.fromJson(value);
        case 'ApiResponseOfProductSubcategoryDto':
          return ApiResponseOfProductSubcategoryDto.fromJson(value);
        case 'ApiResponseOfProductSubcategoryDtoData':
          return ApiResponseOfProductSubcategoryDtoData.fromJson(value);
        case 'ApiResponseOfPublicProfileDto':
          return ApiResponseOfPublicProfileDto.fromJson(value);
        case 'ApiResponseOfPublicProfileDtoData':
          return ApiResponseOfPublicProfileDtoData.fromJson(value);
        case 'ApiResponseOfReminderResponse':
          return ApiResponseOfReminderResponse.fromJson(value);
        case 'ApiResponseOfReminderResponseData':
          return ApiResponseOfReminderResponseData.fromJson(value);
        case 'ApiResponseOfReminderStatusResponse':
          return ApiResponseOfReminderStatusResponse.fromJson(value);
        case 'ApiResponseOfReminderStatusResponseData':
          return ApiResponseOfReminderStatusResponseData.fromJson(value);
        case 'ApiResponseOfRentalCompleteData':
          return ApiResponseOfRentalCompleteData.fromJson(value);
        case 'ApiResponseOfRentalCompleteDataData':
          return ApiResponseOfRentalCompleteDataData.fromJson(value);
        case 'ApiResponseOfRentalCreateData':
          return ApiResponseOfRentalCreateData.fromJson(value);
        case 'ApiResponseOfRentalCreateDataData':
          return ApiResponseOfRentalCreateDataData.fromJson(value);
        case 'ApiResponseOfRentalDetailDto':
          return ApiResponseOfRentalDetailDto.fromJson(value);
        case 'ApiResponseOfRentalDetailDtoData':
          return ApiResponseOfRentalDetailDtoData.fromJson(value);
        case 'ApiResponseOfRentalFinancialBreakdownDto':
          return ApiResponseOfRentalFinancialBreakdownDto.fromJson(value);
        case 'ApiResponseOfRentalFinancialBreakdownDtoData':
          return ApiResponseOfRentalFinancialBreakdownDtoData.fromJson(value);
        case 'ApiResponseOfRentalStatusData':
          return ApiResponseOfRentalStatusData.fromJson(value);
        case 'ApiResponseOfRentalStatusDataData':
          return ApiResponseOfRentalStatusDataData.fromJson(value);
        case 'ApiResponseOfResult':
          return ApiResponseOfResult.fromJson(value);
        case 'ApiResponseOfResultData':
          return ApiResponseOfResultData.fromJson(value);
        case 'ApiResponseOfReviewCreateData':
          return ApiResponseOfReviewCreateData.fromJson(value);
        case 'ApiResponseOfReviewCreateDataData':
          return ApiResponseOfReviewCreateDataData.fromJson(value);
        case 'ApiResponseOfRoleDetailsResponse':
          return ApiResponseOfRoleDetailsResponse.fromJson(value);
        case 'ApiResponseOfRoleDetailsResponseData':
          return ApiResponseOfRoleDetailsResponseData.fromJson(value);
        case 'ApiResponseOfSearchItemsResponse':
          return ApiResponseOfSearchItemsResponse.fromJson(value);
        case 'ApiResponseOfSearchItemsResponseData':
          return ApiResponseOfSearchItemsResponseData.fromJson(value);
        case 'ApiResponseOfString':
          return ApiResponseOfString.fromJson(value);
        case 'ApiResponseOfSupportCreateTicketData':
          return ApiResponseOfSupportCreateTicketData.fromJson(value);
        case 'ApiResponseOfSupportCreateTicketDataData':
          return ApiResponseOfSupportCreateTicketDataData.fromJson(value);
        case 'ApiResponseOfSupportMessageData':
          return ApiResponseOfSupportMessageData.fromJson(value);
        case 'ApiResponseOfSupportMessageDataData':
          return ApiResponseOfSupportMessageDataData.fromJson(value);
        case 'ApiResponseOfSupportTicketStatusData':
          return ApiResponseOfSupportTicketStatusData.fromJson(value);
        case 'ApiResponseOfSupportTicketStatusDataData':
          return ApiResponseOfSupportTicketStatusDataData.fromJson(value);
        case 'ApiResponseOfUpdateUserStatusResponse':
          return ApiResponseOfUpdateUserStatusResponse.fromJson(value);
        case 'ApiResponseOfUpdateUserStatusResponseData':
          return ApiResponseOfUpdateUserStatusResponseData.fromJson(value);
        case 'ApiResponseOfVerificationCreateData':
          return ApiResponseOfVerificationCreateData.fromJson(value);
        case 'ApiResponseOfVerificationCreateDataData':
          return ApiResponseOfVerificationCreateDataData.fromJson(value);
        case 'ApprovalHistoryDto':
          return ApprovalHistoryDto.fromJson(value);
        case 'AssignUserRolesCommand':
          return AssignUserRolesCommand.fromJson(value);
        case 'AssignedVerificationDto':
          return AssignedVerificationDto.fromJson(value);
        case 'AuthLoginData':
          return AuthLoginData.fromJson(value);
        case 'AuthLoginDataUser':
          return AuthLoginDataUser.fromJson(value);
        case 'AuthLoginUser':
          return AuthLoginUser.fromJson(value);
        case 'AuthMeData':
          return AuthMeData.fromJson(value);
        case 'AuthRefreshData':
          return AuthRefreshData.fromJson(value);
        case 'AuthRegisterData':
          return AuthRegisterData.fromJson(value);
        case 'AuthVerifyEmailData':
          return AuthVerifyEmailData.fromJson(value);
        case 'BookedRangeDto':
          return BookedRangeDto.fromJson(value);
        case 'BrandDto':
          return BrandDto.fromJson(value);
        case 'ChatListDto':
          return ChatListDto.fromJson(value);
        case 'ChatMessageDto':
          return ChatMessageDto.fromJson(value);
        case 'ConfirmEmailCommand':
          return ConfirmEmailCommand.fromJson(value);
        case 'ConfirmPhoneVerificationCommand':
          return ConfirmPhoneVerificationCommand.fromJson(value);
        case 'CreateAdminUserCommand':
          return CreateAdminUserCommand.fromJson(value);
        case 'CreateAdminUserResponse':
          return CreateAdminUserResponse.fromJson(value);
        case 'CreateBrandCommand':
          return CreateBrandCommand.fromJson(value);
        case 'CreateCategoryCommand':
          return CreateCategoryCommand.fromJson(value);
        case 'CreateChatCommand':
          return CreateChatCommand.fromJson(value);
        case 'CreateChatResponse':
          return CreateChatResponse.fromJson(value);
        case 'CreateItemCommand':
          return CreateItemCommand.fromJson(value);
        case 'CreateItemImageCommand':
          return CreateItemImageCommand.fromJson(value);
        case 'CreateItemPricingCommand':
          return CreateItemPricingCommand.fromJson(value);
        case 'CreateOrderCommand':
          return CreateOrderCommand.fromJson(value);
        case 'CreatePaymentCommand':
          return CreatePaymentCommand.fromJson(value);
        case 'CreateRentalRequest':
          return CreateRentalRequest.fromJson(value);
        case 'CreateReviewCommand':
          return CreateReviewCommand.fromJson(value);
        case 'CreateRoleCommand':
          return CreateRoleCommand.fromJson(value);
        case 'CreateSubcategoryCommand':
          return CreateSubcategoryCommand.fromJson(value);
        case 'CreateTicketCommand':
          return CreateTicketCommand.fromJson(value);
        case 'CreateVerificationCommand':
          return CreateVerificationCommand.fromJson(value);
        case 'DeleteUserResponse':
          return DeleteUserResponse.fromJson(value);
        case 'ExtendRentalBody':
          return ExtendRentalBody.fromJson(value);
        case 'FavoriteItemDto':
          return FavoriteItemDto.fromJson(value);
        case 'ForgotPasswordCommand':
          return ForgotPasswordCommand.fromJson(value);
        case 'FraudLogDto':
          return FraudLogDto.fromJson(value);
        case 'FraudUserDto':
          return FraudUserDto.fromJson(value);
        case 'GapDto':
          return GapDto.fromJson(value);
        case 'GetAdminUsersResponse':
          return GetAdminUsersResponse.fromJson(value);
        case 'GetChatMessagesResponse':
          return GetChatMessagesResponse.fromJson(value);
        case 'GetChatMessagesResponseChatMetadata':
          return GetChatMessagesResponseChatMetadata.fromJson(value);
        case 'GetChatsResponse':
          return GetChatsResponse.fromJson(value);
        case 'GetExpertAssignedResponse':
          return GetExpertAssignedResponse.fromJson(value);
        case 'GetFraudLogsResponse':
          return GetFraudLogsResponse.fromJson(value);
        case 'GetGapAnalysisResponse':
          return GetGapAnalysisResponse.fromJson(value);
        case 'GetIdVerificationRequestsResponse':
          return GetIdVerificationRequestsResponse.fromJson(value);
        case 'GetItemReviewsResponse':
          return GetItemReviewsResponse.fromJson(value);
        case 'GetKpisResponse':
          return GetKpisResponse.fromJson(value);
        case 'GetMyFavoritesResponse':
          return GetMyFavoritesResponse.fromJson(value);
        case 'GetNotificationsResponse':
          return GetNotificationsResponse.fromJson(value);
        case 'GetOrdersResponse':
          return GetOrdersResponse.fromJson(value);
        case 'GetRecommendationsResponse':
          return GetRecommendationsResponse.fromJson(value);
        case 'GetRentalsResponse':
          return GetRentalsResponse.fromJson(value);
        case 'GetTicketResponse':
          return GetTicketResponse.fromJson(value);
        case 'GetTicketResponseTicket':
          return GetTicketResponseTicket.fromJson(value);
        case 'GetTicketsResponse':
          return GetTicketsResponse.fromJson(value);
        case 'GetVerificationsResponse':
          return GetVerificationsResponse.fromJson(value);
        case 'GetVerificationsResponseItemDetails':
          return GetVerificationsResponseItemDetails.fromJson(value);
        case 'IdVerificationRequestDto':
          return IdVerificationRequestDto.fromJson(value);
        case 'ItemBrandRef':
          return ItemBrandRef.fromJson(value);
        case 'ItemCategoryRef':
          return ItemCategoryRef.fromJson(value);
        case 'ItemCreateData':
          return ItemCreateData.fromJson(value);
        case 'ItemDetailDto':
          return ItemDetailDto.fromJson(value);
        case 'ItemImageDto':
          return ItemImageDto.fromJson(value);
        case 'ItemListDto':
          return ItemListDto.fromJson(value);
        case 'ItemListDtoBrand':
          return ItemListDtoBrand.fromJson(value);
        case 'ItemListDtoCategory':
          return ItemListDtoCategory.fromJson(value);
        case 'ItemListDtoSubcategory':
          return ItemListDtoSubcategory.fromJson(value);
        case 'ItemPricingDto':
          return ItemPricingDto.fromJson(value);
        case 'ItemSubcategoryRef':
          return ItemSubcategoryRef.fromJson(value);
        case 'ItemVerificationDetailsDto':
          return ItemVerificationDetailsDto.fromJson(value);
        case 'ItemVerificationDetailsDtoActiveRental':
          return ItemVerificationDetailsDtoActiveRental.fromJson(value);
        case 'KpiSnapshotDto':
          return KpiSnapshotDto.fromJson(value);
        case 'LoginCommand':
          return LoginCommand.fromJson(value);
        case 'MediaUploadData':
          return MediaUploadData.fromJson(value);
        case 'MessageType':
          return MessageTypeTypeTransformer().decode(value);
        case 'NotificationDto':
          return NotificationDto.fromJson(value);
        case 'NotificationMarkAllData':
          return NotificationMarkAllData.fromJson(value);
        case 'OpenDisputeBody':
          return OpenDisputeBody.fromJson(value);
        case 'OrderCreateData':
          return OrderCreateData.fromJson(value);
        case 'OrderDetailDto':
          return OrderDetailDto.fromJson(value);
        case 'OrderItemDetailDto':
          return OrderItemDetailDto.fromJson(value);
        case 'OrderItemInputDto':
          return OrderItemInputDto.fromJson(value);
        case 'OrderListDto':
          return OrderListDto.fromJson(value);
        case 'OwnerDto':
          return OwnerDto.fromJson(value);
        case 'PaymentCreateData':
          return PaymentCreateData.fromJson(value);
        case 'PaymentDto':
          return PaymentDto.fromJson(value);
        case 'PermissionItemDto':
          return PermissionItemDto.fromJson(value);
        case 'PermissionMetadataDto':
          return PermissionMetadataDto.fromJson(value);
        case 'PersonInfoDto':
          return PersonInfoDto.fromJson(value);
        case 'PostChatMessageCommand':
          return PostChatMessageCommand.fromJson(value);
        case 'PostChatMessageResponse':
          return PostChatMessageResponse.fromJson(value);
        case 'PostSupportMessageCommand':
          return PostSupportMessageCommand.fromJson(value);
        case 'ProductCategoryDto':
          return ProductCategoryDto.fromJson(value);
        case 'ProductSubcategoryDto':
          return ProductSubcategoryDto.fromJson(value);
        case 'PublicProfileDto':
          return PublicProfileDto.fromJson(value);
        case 'RecommendationEntryDto':
          return RecommendationEntryDto.fromJson(value);
        case 'RecommendationItemDto':
          return RecommendationItemDto.fromJson(value);
        case 'RefreshTokenCommand':
          return RefreshTokenCommand.fromJson(value);
        case 'RegisterCommand':
          return RegisterCommand.fromJson(value);
        case 'ReminderResponse':
          return ReminderResponse.fromJson(value);
        case 'ReminderStatusResponse':
          return ReminderStatusResponse.fromJson(value);
        case 'RentalCompleteData':
          return RentalCompleteData.fromJson(value);
        case 'RentalCreateData':
          return RentalCreateData.fromJson(value);
        case 'RentalDetailDto':
          return RentalDetailDto.fromJson(value);
        case 'RentalFinancialBreakdownDto':
          return RentalFinancialBreakdownDto.fromJson(value);
        case 'RentalImageDto':
          return RentalImageDto.fromJson(value);
        case 'RentalImageType':
          return RentalImageTypeTypeTransformer().decode(value);
        case 'RentalInfoDto':
          return RentalInfoDto.fromJson(value);
        case 'RentalListDto':
          return RentalListDto.fromJson(value);
        case 'RentalStatusData':
          return RentalStatusData.fromJson(value);
        case 'RentalTransferDto':
          return RentalTransferDto.fromJson(value);
        case 'RequestPhoneVerificationCommand':
          return RequestPhoneVerificationCommand.fromJson(value);
        case 'RequestWithdrawalCommand':
          return RequestWithdrawalCommand.fromJson(value);
        case 'ResetPasswordCommand':
          return ResetPasswordCommand.fromJson(value);
        case 'ResolveDisputeCommand':
          return ResolveDisputeCommand.fromJson(value);
        case 'RespondExtensionBody':
          return RespondExtensionBody.fromJson(value);
        case 'Result':
          return Result.fromJson(value);
        case 'ReviewCreateData':
          return ReviewCreateData.fromJson(value);
        case 'ReviewDto':
          return ReviewDto.fromJson(value);
        case 'ReviewDto2':
          return ReviewDto2.fromJson(value);
        case 'ReviewIdVerificationCommand':
          return ReviewIdVerificationCommand.fromJson(value);
        case 'ReviewItemCommand':
          return ReviewItemCommand.fromJson(value);
        case 'ReviewerDto':
          return ReviewerDto.fromJson(value);
        case 'RoleDetailsResponse':
          return RoleDetailsResponse.fromJson(value);
        case 'RoleDto':
          return RoleDto.fromJson(value);
        case 'SearchItemsResponse':
          return SearchItemsResponse.fromJson(value);
        case 'SendEmailConfirmationCommand':
          return SendEmailConfirmationCommand.fromJson(value);
        case 'SetHandoffMethodBody':
          return SetHandoffMethodBody.fromJson(value);
        case 'SupportCreateTicketData':
          return SupportCreateTicketData.fromJson(value);
        case 'SupportMessageData':
          return SupportMessageData.fromJson(value);
        case 'SupportMessageDto':
          return SupportMessageDto.fromJson(value);
        case 'SupportTicketEventDto':
          return SupportTicketEventDto.fromJson(value);
        case 'SupportTicketStatusData':
          return SupportTicketStatusData.fromJson(value);
        case 'TicketDetailsDto':
          return TicketDetailsDto.fromJson(value);
        case 'TicketListDto':
          return TicketListDto.fromJson(value);
        case 'TopUpWalletCommand':
          return TopUpWalletCommand.fromJson(value);
        case 'TrackingEntryDto':
          return TrackingEntryDto.fromJson(value);
        case 'UpdateBrandCommand':
          return UpdateBrandCommand.fromJson(value);
        case 'UpdateCategoryCommand':
          return UpdateCategoryCommand.fromJson(value);
        case 'UpdateDeliveryCommand':
          return UpdateDeliveryCommand.fromJson(value);
        case 'UpdateItemCommand':
          return UpdateItemCommand.fromJson(value);
        case 'UpdateRoleCommand':
          return UpdateRoleCommand.fromJson(value);
        case 'UpdateSettingCommand':
          return UpdateSettingCommand.fromJson(value);
        case 'UpdateSubcategoryCommand':
          return UpdateSubcategoryCommand.fromJson(value);
        case 'UpdateTicketStatusCommand':
          return UpdateTicketStatusCommand.fromJson(value);
        case 'UpdateUserCommand':
          return UpdateUserCommand.fromJson(value);
        case 'UpdateUserStatusCommand':
          return UpdateUserStatusCommand.fromJson(value);
        case 'UpdateUserStatusResponse':
          return UpdateUserStatusResponse.fromJson(value);
        case 'UploadIdVerificationCommand':
          return UploadIdVerificationCommand.fromJson(value);
        case 'UploadRentalPhotosBody':
          return UploadRentalPhotosBody.fromJson(value);
        case 'VerificationCreateData':
          return VerificationCreateData.fromJson(value);
        case 'VerificationDto':
          return VerificationDto.fromJson(value);
        case 'VerifyResetTokenCommand':
          return VerifyResetTokenCommand.fromJson(value);
        case 'WalletTransactionDto':
          return WalletTransactionDto.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
