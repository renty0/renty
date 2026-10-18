//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class IdentityApi {
  IdentityApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/user/phone/confirm' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ConfirmPhoneVerificationCommand] confirmPhoneVerificationCommand (required):
  Future<Response> confirmPhoneVerificationWithHttpInfo(ConfirmPhoneVerificationCommand confirmPhoneVerificationCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/user/phone/confirm';

    // ignore: prefer_final_locals
    Object? postBody = confirmPhoneVerificationCommand;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [ConfirmPhoneVerificationCommand] confirmPhoneVerificationCommand (required):
  Future<ApiResponseOfObject?> confirmPhoneVerification(ConfirmPhoneVerificationCommand confirmPhoneVerificationCommand,) async {
    final response = await confirmPhoneVerificationWithHttpInfo(confirmPhoneVerificationCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfObject',) as ApiResponseOfObject;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/id-verifications' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page:
  ///
  /// * [int] limit:
  ///
  /// * [String] status:
  ///
  /// * [String] sortOrder:
  Future<Response> getIdVerificationRequestsWithHttpInfo({ int? page, int? limit, String? status, String? sortOrder, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/id-verifications';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (page != null) {
      queryParams.addAll(_queryParams('', 'Page', page));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'Limit', limit));
    }
    if (status != null) {
      queryParams.addAll(_queryParams('', 'Status', status));
    }
    if (sortOrder != null) {
      queryParams.addAll(_queryParams('', 'SortOrder', sortOrder));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [int] page:
  ///
  /// * [int] limit:
  ///
  /// * [String] status:
  ///
  /// * [String] sortOrder:
  Future<ApiResponseOfGetIdVerificationRequestsResponse?> getIdVerificationRequests({ int? page, int? limit, String? status, String? sortOrder, }) async {
    final response = await getIdVerificationRequestsWithHttpInfo( page: page, limit: limit, status: status, sortOrder: sortOrder, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetIdVerificationRequestsResponse',) as ApiResponseOfGetIdVerificationRequestsResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/user/phone/request' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RequestPhoneVerificationCommand] requestPhoneVerificationCommand (required):
  Future<Response> requestPhoneVerificationWithHttpInfo(RequestPhoneVerificationCommand requestPhoneVerificationCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/user/phone/request';

    // ignore: prefer_final_locals
    Object? postBody = requestPhoneVerificationCommand;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [RequestPhoneVerificationCommand] requestPhoneVerificationCommand (required):
  Future<ApiResponseOfObject?> requestPhoneVerification(RequestPhoneVerificationCommand requestPhoneVerificationCommand,) async {
    final response = await requestPhoneVerificationWithHttpInfo(requestPhoneVerificationCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfObject',) as ApiResponseOfObject;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/admin/id-verifications/{id}/review' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ReviewIdVerificationCommand] reviewIdVerificationCommand (required):
  Future<Response> reviewIdVerificationWithHttpInfo(String id, ReviewIdVerificationCommand reviewIdVerificationCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/id-verifications/{id}/review'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = reviewIdVerificationCommand;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ReviewIdVerificationCommand] reviewIdVerificationCommand (required):
  Future<ApiResponseOfObject?> reviewIdVerification(String id, ReviewIdVerificationCommand reviewIdVerificationCommand,) async {
    final response = await reviewIdVerificationWithHttpInfo(id, reviewIdVerificationCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfObject',) as ApiResponseOfObject;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/user/id/upload' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [UploadIdVerificationCommand] uploadIdVerificationCommand (required):
  Future<Response> uploadIdVerificationWithHttpInfo(UploadIdVerificationCommand uploadIdVerificationCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/user/id/upload';

    // ignore: prefer_final_locals
    Object? postBody = uploadIdVerificationCommand;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [UploadIdVerificationCommand] uploadIdVerificationCommand (required):
  Future<ApiResponseOfObject?> uploadIdVerification(UploadIdVerificationCommand uploadIdVerificationCommand,) async {
    final response = await uploadIdVerificationWithHttpInfo(uploadIdVerificationCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfObject',) as ApiResponseOfObject;
    
    }
    return null;
  }
}
