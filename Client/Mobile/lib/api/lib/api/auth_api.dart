//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/auth/forgot-password' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ForgotPasswordCommand] forgotPasswordCommand (required):
  Future<Response> authForgotPasswordWithHttpInfo(ForgotPasswordCommand forgotPasswordCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/forgot-password';

    // ignore: prefer_final_locals
    Object? postBody = forgotPasswordCommand;

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
  /// * [ForgotPasswordCommand] forgotPasswordCommand (required):
  Future<ApiResponseOfObject?> authForgotPassword(ForgotPasswordCommand forgotPasswordCommand,) async {
    final response = await authForgotPasswordWithHttpInfo(forgotPasswordCommand,);
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

  /// Performs an HTTP 'POST /api/v1/auth/login' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [LoginCommand] loginCommand (required):
  Future<Response> authLoginWithHttpInfo(LoginCommand loginCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = loginCommand;

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
  /// * [LoginCommand] loginCommand (required):
  Future<ApiResponseOfAuthLoginData?> authLogin(LoginCommand loginCommand,) async {
    final response = await authLoginWithHttpInfo(loginCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfAuthLoginData',) as ApiResponseOfAuthLoginData;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/auth/me' operation and returns the [Response].
  Future<Response> authMeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/me';

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

  Future<ApiResponseOfAuthMeData?> authMe() async {
    final response = await authMeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfAuthMeData',) as ApiResponseOfAuthMeData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/refresh' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RefreshTokenCommand] refreshTokenCommand (required):
  Future<Response> authRefreshWithHttpInfo(RefreshTokenCommand refreshTokenCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshTokenCommand;

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
  /// * [RefreshTokenCommand] refreshTokenCommand (required):
  Future<ApiResponseOfAuthRefreshData?> authRefresh(RefreshTokenCommand refreshTokenCommand,) async {
    final response = await authRefreshWithHttpInfo(refreshTokenCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfAuthRefreshData',) as ApiResponseOfAuthRefreshData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/register' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RegisterCommand] registerCommand (required):
  Future<Response> authRegisterWithHttpInfo(RegisterCommand registerCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/register';

    // ignore: prefer_final_locals
    Object? postBody = registerCommand;

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
  /// * [RegisterCommand] registerCommand (required):
  Future<ApiResponseOfAuthRegisterData?> authRegister(RegisterCommand registerCommand,) async {
    final response = await authRegisterWithHttpInfo(registerCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfAuthRegisterData',) as ApiResponseOfAuthRegisterData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/reset-password' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ResetPasswordCommand] resetPasswordCommand (required):
  Future<Response> authResetPasswordWithHttpInfo(ResetPasswordCommand resetPasswordCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/reset-password';

    // ignore: prefer_final_locals
    Object? postBody = resetPasswordCommand;

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
  /// * [ResetPasswordCommand] resetPasswordCommand (required):
  Future<ApiResponseOfObject?> authResetPassword(ResetPasswordCommand resetPasswordCommand,) async {
    final response = await authResetPasswordWithHttpInfo(resetPasswordCommand,);
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

  /// Performs an HTTP 'POST /api/v1/auth/send-verification' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [SendEmailConfirmationCommand] sendEmailConfirmationCommand (required):
  Future<Response> authSendVerificationWithHttpInfo(SendEmailConfirmationCommand sendEmailConfirmationCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/send-verification';

    // ignore: prefer_final_locals
    Object? postBody = sendEmailConfirmationCommand;

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
  /// * [SendEmailConfirmationCommand] sendEmailConfirmationCommand (required):
  Future<ApiResponseOfObject?> authSendVerification(SendEmailConfirmationCommand sendEmailConfirmationCommand,) async {
    final response = await authSendVerificationWithHttpInfo(sendEmailConfirmationCommand,);
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

  /// Performs an HTTP 'PUT /api/v1/auth/me' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [UpdateUserCommand] updateUserCommand (required):
  Future<Response> authUpdateMeWithHttpInfo(UpdateUserCommand updateUserCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/me';

    // ignore: prefer_final_locals
    Object? postBody = updateUserCommand;

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
  /// * [UpdateUserCommand] updateUserCommand (required):
  Future<ApiResponseOfObject?> authUpdateMe(UpdateUserCommand updateUserCommand,) async {
    final response = await authUpdateMeWithHttpInfo(updateUserCommand,);
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

  /// Performs an HTTP 'POST /api/v1/auth/verify-email' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ConfirmEmailCommand] confirmEmailCommand (required):
  Future<Response> authVerifyEmailWithHttpInfo(ConfirmEmailCommand confirmEmailCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/verify-email';

    // ignore: prefer_final_locals
    Object? postBody = confirmEmailCommand;

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
  /// * [ConfirmEmailCommand] confirmEmailCommand (required):
  Future<ApiResponseOfAuthVerifyEmailData?> authVerifyEmail(ConfirmEmailCommand confirmEmailCommand,) async {
    final response = await authVerifyEmailWithHttpInfo(confirmEmailCommand,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApiResponseOfAuthVerifyEmailData',) as ApiResponseOfAuthVerifyEmailData;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/auth/verify-reset-code' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [VerifyResetTokenCommand] verifyResetTokenCommand (required):
  Future<Response> authVerifyResetCodeWithHttpInfo(VerifyResetTokenCommand verifyResetTokenCommand,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/auth/verify-reset-code';

    // ignore: prefer_final_locals
    Object? postBody = verifyResetTokenCommand;

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
  /// * [VerifyResetTokenCommand] verifyResetTokenCommand (required):
  Future<ApiResponseOfObject?> authVerifyResetCode(VerifyResetTokenCommand verifyResetTokenCommand,) async {
    final response = await authVerifyResetCodeWithHttpInfo(verifyResetTokenCommand,);
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
