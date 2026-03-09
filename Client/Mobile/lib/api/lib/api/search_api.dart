//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SearchApi {
  SearchApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'GET /api/v1/search' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] q (required):
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [int] categoryId:
  ///
  /// * [String] city:
  Future<Response> searchItemsWithHttpInfo(String q, int page, int limit, { int? categoryId, String? city, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/search';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'q', q));
    if (categoryId != null) {
      queryParams.addAll(_queryParams('', 'categoryId', categoryId));
    }
    if (city != null) {
      queryParams.addAll(_queryParams('', 'city', city));
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
  /// * [String] q (required):
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [int] categoryId:
  ///
  /// * [String] city:
  Future<ApiResponseOfSearchItemsResponse?> searchItems(String q, int page, int limit, { int? categoryId, String? city, }) async {
    final response = await searchItemsWithHttpInfo(q, page, limit,  categoryId: categoryId, city: city, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfSearchItemsResponse',) as ApiResponseOfSearchItemsResponse;
    
    }
    return null;
  }
}
