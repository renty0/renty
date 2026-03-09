//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BrandsApi {
  BrandsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/brands' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateBrandCommand] createBrandCommand (required):
  Future<Response> createBrandWithHttpInfo(CreateBrandCommand createBrandCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/brands';

    // ignore: prefer_final_locals
    Object? postBody = createBrandCommand;

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
  /// * [CreateBrandCommand] createBrandCommand (required):
  Future<ApiResponseOfBrandDto?> createBrand(CreateBrandCommand createBrandCommand,) async {
    final response = await createBrandWithHttpInfo(createBrandCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfBrandDto',) as ApiResponseOfBrandDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/brands/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> deleteBrandWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/brands/{id}'
      .replaceAll('{id}', id.toString());

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
  /// * [int] id (required):
  Future<ApiResponseOfObject?> deleteBrand(int id,) async {
    final response = await deleteBrandWithHttpInfo(id,);
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

  /// Performs an HTTP 'GET /api/v1/brands/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> getBrandByIdWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/brands/{id}'
      .replaceAll('{id}', id.toString());

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
  /// * [int] id (required):
  Future<ApiResponseOfBrandDto?> getBrandById(int id,) async {
    final response = await getBrandByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfBrandDto',) as ApiResponseOfBrandDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/brands' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] search:
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<Response> getBrandsWithHttpInfo(int page, int limit, { String? search, String? sortBy, String? sortOrder, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/brands';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
      queryParams.addAll(_queryParams('', 'page', page));
      queryParams.addAll(_queryParams('', 'limit', limit));
    if (sortBy != null) {
      queryParams.addAll(_queryParams('', 'sortBy', sortBy));
    }
    if (sortOrder != null) {
      queryParams.addAll(_queryParams('', 'sortOrder', sortOrder));
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
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] search:
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<ApiResponseOfListOfBrandDto?> getBrands(int page, int limit, { String? search, String? sortBy, String? sortOrder, }) async {
    final response = await getBrandsWithHttpInfo(page, limit,  search: search, sortBy: sortBy, sortOrder: sortOrder, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfBrandDto',) as ApiResponseOfListOfBrandDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/brands/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateBrandCommand] updateBrandCommand (required):
  Future<Response> updateBrandWithHttpInfo(int id, UpdateBrandCommand updateBrandCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/brands/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateBrandCommand;

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
  /// * [int] id (required):
  ///
  /// * [UpdateBrandCommand] updateBrandCommand (required):
  Future<ApiResponseOfBrandDto?> updateBrand(int id, UpdateBrandCommand updateBrandCommand,) async {
    final response = await updateBrandWithHttpInfo(id, updateBrandCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfBrandDto',) as ApiResponseOfBrandDto;
    
    }
    return null;
  }
}
