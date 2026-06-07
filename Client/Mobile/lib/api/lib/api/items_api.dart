//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ItemsApi {
  ItemsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/items' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateItemCommand] createItemCommand (required):
  Future<Response> createItemWithHttpInfo(CreateItemCommand createItemCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/items';

    // ignore: prefer_final_locals
    Object? postBody = createItemCommand;

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
  /// * [CreateItemCommand] createItemCommand (required):
  Future<ApiResponseOfItemCreateData?> createItem(CreateItemCommand createItemCommand,) async {
    final response = await createItemWithHttpInfo(createItemCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfItemCreateData',) as ApiResponseOfItemCreateData;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/items/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> deleteItemWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/items/{id}'
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
  Future<ApiResponseOfObject?> deleteItem(String id,) async {
    final response = await deleteItemWithHttpInfo(id,);
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

  /// Performs an HTTP 'GET /api/v1/items/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getItemByIdWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/items/{id}'
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
  Future<ApiResponseOfItemDetailDto?> getItemById(String id,) async {
    final response = await getItemByIdWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfItemDetailDto',) as ApiResponseOfItemDetailDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/items' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  /// * [int] limit (required):
  /// * [int] categoryId:
  /// * [int] subcategoryId:
  /// * [String] city:
  /// * [num] minPrice:
  /// * [num] maxPrice:
  /// * [DateTime] startDate:
  /// * [DateTime] endDate:
  /// * [num] minRating:
  /// * [String] type:
  /// * [String] condition:
  /// * [String] sort:
  /// * [String] sortOrder:
  /// * [String] owner:
  Future<Response> getItemsWithHttpInfo(int page, int limit, { int? categoryId, int? subcategoryId, String? city, num? minPrice, num? maxPrice, DateTime? startDate, DateTime? endDate, num? minRating, String? type, String? condition, String? sort, String? sortOrder, String? owner, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/items';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'page', page));
      queryParams.addAll(_queryParams('', 'limit', limit));
    if (categoryId != null) {
      queryParams.addAll(_queryParams('', 'categoryId', categoryId));
    }
    if (subcategoryId != null) {
      queryParams.addAll(_queryParams('', 'subcategoryId', subcategoryId));
    }
    if (city != null) {
      queryParams.addAll(_queryParams('', 'city', city));
    }
    if (minPrice != null) {
      queryParams.addAll(_queryParams('', 'minPrice', minPrice));
    }
    if (maxPrice != null) {
      queryParams.addAll(_queryParams('', 'maxPrice', maxPrice));
    }
    if (startDate != null) {
      queryParams.addAll(_queryParams('', 'startDate', startDate.toIso8601String()));
    }
    if (endDate != null) {
      queryParams.addAll(_queryParams('', 'endDate', endDate.toIso8601String()));
    }
    if (minRating != null) {
      queryParams.addAll(_queryParams('', 'minRating', minRating));
    }
    if (type != null) {
      queryParams.addAll(_queryParams('', 'type', type));
    }
    if (condition != null) {
      queryParams.addAll(_queryParams('', 'condition', condition));
    }
    if (sort != null) {
      queryParams.addAll(_queryParams('', 'sort', sort));
    }
    if (sortOrder != null) {
      queryParams.addAll(_queryParams('', 'sortOrder', sortOrder));
    }
    if (owner != null) {
      queryParams.addAll(_queryParams('', 'owner', owner));
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
  /// * [int] page (required):
  /// * [int] limit (required):
  /// * [int] categoryId:
  /// * [int] subcategoryId:
  /// * [String] city:
  /// * [num] minPrice:
  /// * [num] maxPrice:
  /// * [DateTime] startDate:
  /// * [DateTime] endDate:
  /// * [num] minRating:
  /// * [String] type:
  /// * [String] condition:
  /// * [String] sort:
  /// * [String] sortOrder:
  /// * [String] owner:
  Future<ApiResponseOfListOfItemListDto?> getItems(int page, int limit, { int? categoryId, int? subcategoryId, String? city, num? minPrice, num? maxPrice, DateTime? startDate, DateTime? endDate, num? minRating, String? type, String? condition, String? sort, String? sortOrder, String? owner, }) async {
    final response = await getItemsWithHttpInfo(page, limit, categoryId: categoryId, subcategoryId: subcategoryId, city: city, minPrice: minPrice, maxPrice: maxPrice, startDate: startDate, endDate: endDate, minRating: minRating, type: type, condition: condition, sort: sort, sortOrder: sortOrder, owner: owner, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfItemListDto',) as ApiResponseOfListOfItemListDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/items/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateItemCommand] updateItemCommand (required):
  Future<Response> updateItemWithHttpInfo(String id, UpdateItemCommand updateItemCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/items/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateItemCommand;

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
  /// * [UpdateItemCommand] updateItemCommand (required):
  Future<ApiResponseOfItemDetailDto?> updateItem(String id, UpdateItemCommand updateItemCommand,) async {
    final response = await updateItemWithHttpInfo(id, updateItemCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfItemDetailDto',) as ApiResponseOfItemDetailDto;
    
    }
    return null;
  }
}
