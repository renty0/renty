//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SupportApi {
  SupportApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/support/tickets/{id}/assign' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> assignSupportTicketWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets/{id}/assign'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  Future<ApiResponseOfObject?> assignSupportTicket(String id,) async {
    final response = await assignSupportTicketWithHttpInfo(id,);
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

  /// Performs an HTTP 'POST /api/v1/support/tickets' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateTicketCommand] createTicketCommand (required):
  Future<Response> createSupportTicketWithHttpInfo(CreateTicketCommand createTicketCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets';

    // ignore: prefer_final_locals
    Object? postBody = createTicketCommand;

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
  /// * [CreateTicketCommand] createTicketCommand (required):
  Future<ApiResponseOfSupportCreateTicketData?> createSupportTicket(CreateTicketCommand createTicketCommand,) async {
    final response = await createSupportTicketWithHttpInfo(createTicketCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfSupportCreateTicketData',) as ApiResponseOfSupportCreateTicketData;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/support/tickets/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getSupportTicketDetailsWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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
  /// * [String] id (required):
  Future<ApiResponseOfGetTicketResponse?> getSupportTicketDetails(String id,) async {
    final response = await getSupportTicketDetailsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetTicketResponse',) as ApiResponseOfGetTicketResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/support/tickets' operation and returns the [Response].
  Future<Response> getSupportTicketsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  Future<ApiResponseOfGetTicketsResponse?> getSupportTickets() async {
    final response = await getSupportTicketsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetTicketsResponse',) as ApiResponseOfGetTicketsResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/support/tickets/{id}/messages' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [PostSupportMessageCommand] postSupportMessageCommand (required):
  Future<Response> postSupportMessageWithHttpInfo(String id, PostSupportMessageCommand postSupportMessageCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets/{id}/messages'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = postSupportMessageCommand;

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
  /// * [PostSupportMessageCommand] postSupportMessageCommand (required):
  Future<ApiResponseOfSupportMessageData?> postSupportMessage(String id, PostSupportMessageCommand postSupportMessageCommand,) async {
    final response = await postSupportMessageWithHttpInfo(id, postSupportMessageCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfSupportMessageData',) as ApiResponseOfSupportMessageData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/support/tickets/{id}/unassign' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> unassignSupportTicketWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets/{id}/unassign'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  Future<ApiResponseOfObject?> unassignSupportTicket(String id,) async {
    final response = await unassignSupportTicketWithHttpInfo(id,);
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

  /// Performs an HTTP 'PUT /api/v1/support/tickets/{id}/status' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateTicketStatusCommand] updateTicketStatusCommand (required):
  Future<Response> updateSupportTicketStatusWithHttpInfo(String id, UpdateTicketStatusCommand updateTicketStatusCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/support/tickets/{id}/status'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateTicketStatusCommand;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
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
  /// * [UpdateTicketStatusCommand] updateTicketStatusCommand (required):
  Future<ApiResponseOfSupportTicketStatusData?> updateSupportTicketStatus(String id, UpdateTicketStatusCommand updateTicketStatusCommand,) async {
    final response = await updateSupportTicketStatusWithHttpInfo(id, updateTicketStatusCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfSupportTicketStatusData',) as ApiResponseOfSupportTicketStatusData;
    
    }
    return null;
  }
}
