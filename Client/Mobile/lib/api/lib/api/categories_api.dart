//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CategoriesApi {
  CategoriesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/categories' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateCategoryCommand] createCategoryCommand (required):
  Future<Response> createCategoryWithHttpInfo(CreateCategoryCommand createCategoryCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories';

    // ignore: prefer_final_locals
    Object? postBody = createCategoryCommand;

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
  /// * [CreateCategoryCommand] createCategoryCommand (required):
  Future<ApiResponseOfProductCategoryDto?> createCategory(CreateCategoryCommand createCategoryCommand,) async {
    final response = await createCategoryWithHttpInfo(createCategoryCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductCategoryDto',) as ApiResponseOfProductCategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/categories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> deleteCategoryWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories/{id}'
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
  Future<ApiResponseOfObject?> deleteCategory(int id,) async {
    final response = await deleteCategoryWithHttpInfo(id,);
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

  /// Performs an HTTP 'GET /api/v1/categories' operation and returns the [Response].
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
  Future<Response> getCategoriesWithHttpInfo(int page, int limit, { String? search, String? sortBy, String? sortOrder, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories';

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
  Future<ApiResponseOfListOfProductCategoryDto?> getCategories(int page, int limit, { String? search, String? sortBy, String? sortOrder, }) async {
    final response = await getCategoriesWithHttpInfo(page, limit,  search: search, sortBy: sortBy, sortOrder: sortOrder, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfProductCategoryDto',) as ApiResponseOfListOfProductCategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/categories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> getCategoryByIdWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories/{id}'
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
  Future<ApiResponseOfProductCategoryDto?> getCategoryById(int id,) async {
    final response = await getCategoryByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductCategoryDto',) as ApiResponseOfProductCategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/categories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateCategoryCommand] updateCategoryCommand (required):
  Future<Response> updateCategoryWithHttpInfo(int id, UpdateCategoryCommand updateCategoryCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateCategoryCommand;

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
  /// * [UpdateCategoryCommand] updateCategoryCommand (required):
  Future<ApiResponseOfProductCategoryDto?> updateCategory(int id, UpdateCategoryCommand updateCategoryCommand,) async {
    final response = await updateCategoryWithHttpInfo(id, updateCategoryCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductCategoryDto',) as ApiResponseOfProductCategoryDto;
    
    }
    return null;
  }
}
