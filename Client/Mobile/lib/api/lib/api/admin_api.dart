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

  /// Performs an HTTP 'PUT /api/v1/admin/users/{id}/roles' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [AssignUserRolesCommand] assignUserRolesCommand (required):
  Future<Response> assignUserRolesWithHttpInfo(int id, AssignUserRolesCommand assignUserRolesCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/users/{id}/roles'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = assignUserRolesCommand;

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
  /// * [AssignUserRolesCommand] assignUserRolesCommand (required):
  Future<ApiResponseOfResult?> assignUserRoles(int id, AssignUserRolesCommand assignUserRolesCommand,) async {
    final response = await assignUserRolesWithHttpInfo(id, assignUserRolesCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfResult',) as ApiResponseOfResult;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/admin/users' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateAdminUserCommand] createAdminUserCommand (required):
  Future<Response> createAdminUserWithHttpInfo(CreateAdminUserCommand createAdminUserCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/users';

    // ignore: prefer_final_locals
    Object? postBody = createAdminUserCommand;

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
  /// * [CreateAdminUserCommand] createAdminUserCommand (required):
  Future<ApiResponseOfCreateAdminUserResponse?> createAdminUser(CreateAdminUserCommand createAdminUserCommand,) async {
    final response = await createAdminUserWithHttpInfo(createAdminUserCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfCreateAdminUserResponse',) as ApiResponseOfCreateAdminUserResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/admin/roles' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [CreateRoleCommand] createRoleCommand (required):
  Future<Response> createRoleWithHttpInfo(CreateRoleCommand createRoleCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/roles';

    // ignore: prefer_final_locals
    Object? postBody = createRoleCommand;

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
  /// * [CreateRoleCommand] createRoleCommand (required):
  Future<ApiResponseOfResult?> createRole(CreateRoleCommand createRoleCommand,) async {
    final response = await createRoleWithHttpInfo(createRoleCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfResult',) as ApiResponseOfResult;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/admin/roles/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> deleteRoleWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/roles/{id}'
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
  Future<ApiResponseOfResult?> deleteRole(int id,) async {
    final response = await deleteRoleWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfResult',) as ApiResponseOfResult;
    
    }
    return null;
  }

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
  Future<ApiResponseOfGetGapAnalysisResponse?> getAdminGapAnalysis(int limit, { String? period, }) async {
    final response = await getAdminGapAnalysisWithHttpInfo(limit,  period: period, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetGapAnalysisResponse',) as ApiResponseOfGetGapAnalysisResponse;
    
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
  Future<ApiResponseOfGetKpisResponse?> getAdminKpis({ String? period, DateTime? from, DateTime? to, }) async {
    final response = await getAdminKpisWithHttpInfo( period: period, from: from, to: to, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetKpisResponse',) as ApiResponseOfGetKpisResponse;
    
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

  Future<ApiResponseOfKpiSnapshotDto?> getAdminLatestKpi() async {
    final response = await getAdminLatestKpiWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfKpiSnapshotDto',) as ApiResponseOfKpiSnapshotDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/rentals/{id}/financials' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getAdminRentalFinancialsWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/rentals/{id}/financials'
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
  Future<ApiResponseOfRentalFinancialBreakdownDto?> getAdminRentalFinancials(String id,) async {
    final response = await getAdminRentalFinancialsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRentalFinancialBreakdownDto',) as ApiResponseOfRentalFinancialBreakdownDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/roles' operation and returns the [Response].
  Future<Response> getAdminRolesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/roles';

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

  Future<ApiResponseOfListOfRoleDto?> getAdminRoles() async {
    final response = await getAdminRolesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfRoleDto',) as ApiResponseOfListOfRoleDto;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/users' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] page (required):
  ///
  /// * [int] limit (required):
  ///
  /// * [String] searchTerm:
  Future<Response> getAdminUsersWithHttpInfo(int page, int limit, { String? searchTerm, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/users';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (searchTerm != null) {
      queryParams.addAll(_queryParams('', 'searchTerm', searchTerm));
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
  /// * [String] searchTerm:
  Future<ApiResponseOfGetAdminUsersResponse?> getAdminUsers(int page, int limit, { String? searchTerm, }) async {
    final response = await getAdminUsersWithHttpInfo(page, limit,  searchTerm: searchTerm, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetAdminUsersResponse',) as ApiResponseOfGetAdminUsersResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/permissions' operation and returns the [Response].
  Future<Response> getAvailablePermissionsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/permissions';

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

  Future<ApiResponseOfListOfPermissionMetadataDto?> getAvailablePermissions() async {
    final response = await getAvailablePermissionsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfListOfPermissionMetadataDto',) as ApiResponseOfListOfPermissionMetadataDto;
    
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
  Future<ApiResponseOfGetFraudLogsResponse?> getFraudLogs(int page, int limit, { String? decision, double? minRisk, }) async {
    final response = await getFraudLogsWithHttpInfo(page, limit,  decision: decision, minRisk: minRisk, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfGetFraudLogsResponse',) as ApiResponseOfGetFraudLogsResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/admin/roles/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> getRoleDetailsWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/roles/{id}'
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
  Future<ApiResponseOfRoleDetailsResponse?> getRoleDetails(int id,) async {
    final response = await getRoleDetailsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfRoleDetailsResponse',) as ApiResponseOfRoleDetailsResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'PUT /api/v1/admin/roles/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateRoleCommand] updateRoleCommand (required):
  Future<Response> updateRoleWithHttpInfo(int id, UpdateRoleCommand updateRoleCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/roles/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateRoleCommand;

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
  /// * [UpdateRoleCommand] updateRoleCommand (required):
  Future<ApiResponseOfResult?> updateRole(int id, UpdateRoleCommand updateRoleCommand,) async {
    final response = await updateRoleWithHttpInfo(id, updateRoleCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfResult',) as ApiResponseOfResult;
    
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
  Future<ApiResponseOfUpdateUserStatusResponse?> updateUserStatus(int id, UpdateUserStatusCommand updateUserStatusCommand,) async {
    final response = await updateUserStatusWithHttpInfo(id, updateUserStatusCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfUpdateUserStatusResponse',) as ApiResponseOfUpdateUserStatusResponse;
    
    }
    return null;
  }
}
