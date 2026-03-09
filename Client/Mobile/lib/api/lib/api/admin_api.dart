//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AdminApi {
  AdminApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'GET /api/v1/admin/gap' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] limit (required):
  ///
  /// * [String] period:
  Future<Response> getAdminGapAnalysisWithHttpInfo(int limit, { String? period, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/gap';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (period != null) {
      queryParams.addAll(_queryParams('', 'period', period));
    }
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
  /// * [int] limit (required):
  ///
  /// * [String] period:
  Future<ApiResponseOfObject?> getAdminGapAnalysis(int limit, { String? period, }) async {
    final response = await getAdminGapAnalysisWithHttpInfo(limit,  period: period, );
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

  /// Performs an HTTP 'GET /api/v1/admin/kpis' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] period:
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  Future<Response> getAdminKpisWithHttpInfo({ String? period, DateTime? from, DateTime? to, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/kpis';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (period != null) {
      queryParams.addAll(_queryParams('', 'period', period));
    }
    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (to != null) {
      queryParams.addAll(_queryParams('', 'to', to));
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
  /// * [String] period:
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  Future<ApiResponseOfObject?> getAdminKpis({ String? period, DateTime? from, DateTime? to, }) async {
    final response = await getAdminKpisWithHttpInfo( period: period, from: from, to: to, );
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

  /// Performs an HTTP 'GET /api/v1/admin/kpis/latest' operation and returns the [Response].
  Future<Response> getAdminLatestKpiWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/kpis/latest';

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

  Future<ApiResponseOfObject?> getAdminLatestKpi() async {
    final response = await getAdminLatestKpiWithHttpInfo();
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

  /// Performs an HTTP 'GET /api/v1/admin/users' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  Future<Response> getAdminUsersWithHttpInfo(int page, int limit,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/users';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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
  Future<ApiResponseOfObject?> getAdminUsers(int page, int limit,) async {
    final response = await getAdminUsersWithHttpInfo(page, limit,);
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

  /// Performs an HTTP 'GET /api/v1/admin/fraud' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] decision:
  ///
  /// * [double] minRisk:
  Future<Response> getFraudLogsWithHttpInfo(int page, int limit, { String? decision, double? minRisk, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/fraud';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (decision != null) {
      queryParams.addAll(_queryParams('', 'decision', decision));
    }
    if (minRisk != null) {
      queryParams.addAll(_queryParams('', 'minRisk', minRisk));
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
  /// * [String] decision:
  ///
  /// * [double] minRisk:
  Future<ApiResponseOfObject?> getFraudLogs(int page, int limit, { String? decision, double? minRisk, }) async {
    final response = await getFraudLogsWithHttpInfo(page, limit,  decision: decision, minRisk: minRisk, );
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

  /// Performs an HTTP 'PUT /api/v1/admin/users/{id}/status' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateUserStatusCommand] updateUserStatusCommand (required):
  Future<Response> updateUserStatusWithHttpInfo(int id, UpdateUserStatusCommand updateUserStatusCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/users/{id}/status'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateUserStatusCommand;

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
  /// * [UpdateUserStatusCommand] updateUserStatusCommand (required):
  Future<ApiResponseOfObject?> updateUserStatus(int id, UpdateUserStatusCommand updateUserStatusCommand,) async {
    final response = await updateUserStatusWithHttpInfo(id, updateUserStatusCommand,);
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
