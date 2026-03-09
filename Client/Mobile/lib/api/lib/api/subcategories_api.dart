//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SubcategoriesApi {
  SubcategoriesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/subcategories' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateSubcategoryCommand] createSubcategoryCommand (required):
  Future<Response> createSubcategoryWithHttpInfo(CreateSubcategoryCommand createSubcategoryCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/subcategories';

    // ignore: prefer_final_locals
    Object? postBody = createSubcategoryCommand;

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
  /// * [CreateSubcategoryCommand] createSubcategoryCommand (required):
  Future<ApiResponseOfProductSubcategoryDto?> createSubcategory(CreateSubcategoryCommand createSubcategoryCommand,) async {
    final response = await createSubcategoryWithHttpInfo(createSubcategoryCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductSubcategoryDto',) as ApiResponseOfProductSubcategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/subcategories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> deleteSubcategoryWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/subcategories/{id}'
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
  Future<ApiResponseOfObject?> deleteSubcategory(int id,) async {
    final response = await deleteSubcategoryWithHttpInfo(id,);
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

  /// Performs an HTTP 'GET /api/v1/subcategories' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [int] categoryId:
  ///
  /// * [String] search:
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<Response> getSubcategoriesWithHttpInfo(int page, int limit, { int? categoryId, String? search, String? sortBy, String? sortOrder, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/subcategories';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (categoryId != null) {
      queryParams.addAll(_queryParams('', 'categoryId', categoryId));
    }
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
  /// * [int] categoryId:
  ///
  /// * [String] search:
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<ApiResponseOfListOfProductSubcategoryDto?> getSubcategories(int page, int limit, { int? categoryId, String? search, String? sortBy, String? sortOrder, }) async {
    final response = await getSubcategoriesWithHttpInfo(page, limit,  categoryId: categoryId, search: search, sortBy: sortBy, sortOrder: sortOrder, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfProductSubcategoryDto',) as ApiResponseOfListOfProductSubcategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/categories/{categoryId}/subcategories' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] categoryId (required):
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<Response> getSubcategoriesByCategoryWithHttpInfo(int categoryId, int page, int limit, { String? sortBy, String? sortOrder, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/categories/{categoryId}/subcategories'
      .replaceAll('{categoryId}', categoryId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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
  /// * [int] categoryId (required):
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] sortBy:
  ///
  /// * [String] sortOrder:
  Future<ApiResponseOfListOfProductSubcategoryDto?> getSubcategoriesByCategory(int categoryId, int page, int limit, { String? sortBy, String? sortOrder, }) async {
    final response = await getSubcategoriesByCategoryWithHttpInfo(categoryId, page, limit,  sortBy: sortBy, sortOrder: sortOrder, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfProductSubcategoryDto',) as ApiResponseOfListOfProductSubcategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/subcategories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> getSubcategoryByIdWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/subcategories/{id}'
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
  Future<ApiResponseOfProductSubcategoryDto?> getSubcategoryById(int id,) async {
    final response = await getSubcategoryByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductSubcategoryDto',) as ApiResponseOfProductSubcategoryDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/subcategories/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateSubcategoryCommand] updateSubcategoryCommand (required):
  Future<Response> updateSubcategoryWithHttpInfo(int id, UpdateSubcategoryCommand updateSubcategoryCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/subcategories/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateSubcategoryCommand;

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
  /// * [UpdateSubcategoryCommand] updateSubcategoryCommand (required):
  Future<ApiResponseOfProductSubcategoryDto?> updateSubcategory(int id, UpdateSubcategoryCommand updateSubcategoryCommand,) async {
    final response = await updateSubcategoryWithHttpInfo(id, updateSubcategoryCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfProductSubcategoryDto',) as ApiResponseOfProductSubcategoryDto;
    
    }
    return null;
  }
}
