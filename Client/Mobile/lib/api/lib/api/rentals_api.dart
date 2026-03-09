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

  /// Performs an HTTP 'PUT /api/v1/rentals/{id}/activate' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> activateRentalWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals/{id}/activate'
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
  Future<ApiResponseOfRentalStatusData?> activateRental(String id,) async {
    final response = await activateRentalWithHttpInfo(id,);
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
  /// * [CreateRentalCommand] createRentalCommand (required):
  Future<Response> createRentalWithHttpInfo(CreateRentalCommand createRentalCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/rentals';

    // ignore: prefer_final_locals
    Object? postBody = createRentalCommand;

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
  /// * [CreateRentalCommand] createRentalCommand (required):
  Future<ApiResponseOfRentalCreateData?> createRental(CreateRentalCommand createRentalCommand,) async {
    final response = await createRentalWithHttpInfo(createRentalCommand,);
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
  Future<Response> getRentalsWithHttpInfo(int page, int limit, { String? status, }) async {
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
  Future<ApiResponseOfGetRentalsResponse?> getRentals(int page, int limit, { String? status, }) async {
    final response = await getRentalsWithHttpInfo(page, limit,  status: status, );
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
}
