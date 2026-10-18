//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class RentalsApi {
  RentalsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'DELETE /api/v1/rentals/{id}/request-expert' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> cancelExpertReviewWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/request-expert'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
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
  Future<ApiResponseOfObject?> cancelExpertReview(String id,) async {
    final response = await cancelExpertReviewWithHttpInfo(id,);
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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/cancel' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> cancelRentalWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/cancel'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  Future<ApiResponseOfRentalStatusData?> cancelRental(String id,) async {
    final response = await cancelRentalWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalStatusData',) as ApiResponseOfRentalStatusData;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/complete' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [bool] damaged (required):
  Future<Response> completeRentalWithHttpInfo(String id, bool damaged,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/complete'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'damaged', damaged));

    const contentTypes = <String>[];


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
  /// * [bool] damaged (required):
  Future<ApiResponseOfRentalCompleteData?> completeRental(String id, bool damaged,) async {
    final response = await completeRentalWithHttpInfo(id, damaged,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalCompleteData',) as ApiResponseOfRentalCompleteData;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/confirm' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> confirmRentalWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/confirm'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  Future<ApiResponseOfRentalStatusData?> confirmRental(String id,) async {
    final response = await confirmRentalWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalStatusData',) as ApiResponseOfRentalStatusData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/rentals' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateRentalRequest] createRentalRequest (required):
  Future<Response> createRentalWithHttpInfo(CreateRentalRequest createRentalRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals';

    // ignore: prefer_final_locals
    Object? postBody = createRentalRequest;

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
  /// * [CreateRentalRequest] createRentalRequest (required):
  Future<ApiResponseOfRentalCreateData?> createRental(CreateRentalRequest createRentalRequest,) async {
    final response = await createRentalWithHttpInfo(createRentalRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalCreateData',) as ApiResponseOfRentalCreateData;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/rentals/{id}/photos' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] imageUrl (required):
  Future<Response> deleteRentalPhotoWithHttpInfo(String id, String imageUrl,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/photos'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'imageUrl', imageUrl));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
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
  /// * [String] imageUrl (required):
  Future<ApiResponseOfObject?> deleteRentalPhoto(String id, String imageUrl,) async {
    final response = await deleteRentalPhotoWithHttpInfo(id, imageUrl,);
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

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/transfers/expert-return' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] method:
  Future<Response> generateExpertToOwnerTransfersWithHttpInfo(String id, { String? method, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/transfers/expert-return'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (method != null) {
      queryParams.addAll(_queryParams('', 'method', method));
    }

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
  ///
  /// * [String] method:
  Future<ApiResponseOfObject?> generateExpertToOwnerTransfers(String id, { String? method, }) async {
    final response = await generateExpertToOwnerTransfersWithHttpInfo(id,  method: method, );
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

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/transfers/handoff-from-hub' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] method:
  Future<Response> generateHandoffFromHubTransfersWithHttpInfo(String id, { String? method, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/transfers/handoff-from-hub'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (method != null) {
      queryParams.addAll(_queryParams('', 'method', method));
    }

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
  ///
  /// * [String] method:
  Future<ApiResponseOfObject?> generateHandoffFromHubTransfers(String id, { String? method, }) async {
    final response = await generateHandoffFromHubTransfersWithHttpInfo(id,  method: method, );
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

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/transfers/generate' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] method:
  Future<Response> generateTransfersWithHttpInfo(String id, { String? method, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/transfers/generate'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (method != null) {
      queryParams.addAll(_queryParams('', 'method', method));
    }

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
  ///
  /// * [String] method:
  Future<ApiResponseOfObject?> generateTransfers(String id, { String? method, }) async {
    final response = await generateTransfersWithHttpInfo(id,  method: method, );
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

  /// Performs an HTTP 'GET /api/v1/rentals/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getRentalByIdWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}'
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
  Future<ApiResponseOfRentalDetailDto?> getRentalById(String id,) async {
    final response = await getRentalByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalDetailDto',) as ApiResponseOfRentalDetailDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/rentals' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] status:
  ///
  /// * [String] role:
  Future<Response> getRentalsWithHttpInfo(int page, int limit, { String? status, String? role, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (role != null) {
      queryParams.addAll(_queryParams('', 'role', role));
    }
      queryParams.addAll(_queryParams('', 'page', page));
      queryParams.addAll(_queryParams('', 'limit', limit));

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
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] status:
  ///
  /// * [String] role:
  Future<ApiResponseOfGetRentalsResponse?> getRentals(int page, int limit, { String? status, String? role, }) async {
    final response = await getRentalsWithHttpInfo(page, limit,  status: status, role: role, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetRentalsResponse',) as ApiResponseOfGetRentalsResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/dispute' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [OpenDisputeBody] openDisputeBody (required):
  Future<Response> openRentalDisputeWithHttpInfo(String id, OpenDisputeBody openDisputeBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/dispute'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = openDisputeBody;

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
  /// * [OpenDisputeBody] openDisputeBody (required):
  Future<ApiResponseOfObject?> openRentalDispute(String id, OpenDisputeBody openDisputeBody,) async {
    final response = await openRentalDisputeWithHttpInfo(id, openDisputeBody,);
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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/request-expert' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> requestExpertReviewWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/request-expert'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  Future<ApiResponseOfObject?> requestExpertReview(String id,) async {
    final response = await requestExpertReviewWithHttpInfo(id,);
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

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/extend' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ExtendRentalBody] extendRentalBody (required):
  Future<Response> requestRentalExtensionWithHttpInfo(String id, ExtendRentalBody extendRentalBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/extend'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = extendRentalBody;

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
  /// * [ExtendRentalBody] extendRentalBody (required):
  Future<ApiResponseOfObject?> requestRentalExtension(String id, ExtendRentalBody extendRentalBody,) async {
    final response = await requestRentalExtensionWithHttpInfo(id, extendRentalBody,);
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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/extend/{extId}/respond' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] extId (required):
  ///
  /// * [RespondExtensionBody] respondExtensionBody (required):
  Future<Response> respondToExtensionWithHttpInfo(String id, String extId, RespondExtensionBody respondExtensionBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/extend/{extId}/respond'
      .replaceAll('{id}', id)
      .replaceAll('{extId}', extId);

    // ignore: prefer_final_locals
    Object? postBody = respondExtensionBody;

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
  /// * [String] extId (required):
  ///
  /// * [RespondExtensionBody] respondExtensionBody (required):
  Future<ApiResponseOfObject?> respondToExtension(String id, String extId, RespondExtensionBody respondExtensionBody,) async {
    final response = await respondToExtensionWithHttpInfo(id, extId, respondExtensionBody,);
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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/handoff' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [SetHandoffMethodBody] setHandoffMethodBody (required):
  Future<Response> setHandoffMethodWithHttpInfo(String id, SetHandoffMethodBody setHandoffMethodBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/handoff'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = setHandoffMethodBody;

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
  /// * [SetHandoffMethodBody] setHandoffMethodBody (required):
  Future<ApiResponseOfRentalStatusData?> setHandoffMethod(String id, SetHandoffMethodBody setHandoffMethodBody,) async {
    final response = await setHandoffMethodWithHttpInfo(id, setHandoffMethodBody,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalStatusData',) as ApiResponseOfRentalStatusData;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/possession' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] action (required):
  ///
  /// * [String] method (required):
  Future<Response> updatePossessionWithHttpInfo(String id, String action, String method,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/possession'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'action', action));
      queryParams.addAll(_queryParams('', 'method', method));

    const contentTypes = <String>[];


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
  /// * [String] action (required):
  ///
  /// * [String] method (required):
  Future<ApiResponseOfObject?> updatePossession(String id, String action, String method,) async {
    final response = await updatePossessionWithHttpInfo(id, action, method,);
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

  /// Performs an HTTP 'POST /api/v1/rentals/{id}/photos' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UploadRentalPhotosBody] uploadRentalPhotosBody (required):
  Future<Response> uploadRentalPhotosWithHttpInfo(String id, UploadRentalPhotosBody uploadRentalPhotosBody,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/photos'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = uploadRentalPhotosBody;

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
  /// * [UploadRentalPhotosBody] uploadRentalPhotosBody (required):
  Future<ApiResponseOfObject?> uploadRentalPhotos(String id, UploadRentalPhotosBody uploadRentalPhotosBody,) async {
    final response = await uploadRentalPhotosWithHttpInfo(id, uploadRentalPhotosBody,);
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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/verify-transfer' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] body (required):
  Future<Response> verifyTransferWithHttpInfo(String id, String body,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/verify-transfer'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = body;

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
  /// * [String] body (required):
  Future<ApiResponseOfObject?> verifyTransfer(String id, String body,) async {
    final response = await verifyTransferWithHttpInfo(id, body,);
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
