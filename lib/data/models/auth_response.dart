import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

/// {"success": true, "accessToken": "eyJ...", "tokenType": "Bearer", "expiresIn": 3600}
@JsonSerializable(createToJson: false)
class AuthResponse {
  const AuthResponse({
    this.success = true,
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  @JsonKey(defaultValue: true)
  final bool success;
  final String accessToken;

  @JsonKey(defaultValue: 'Bearer')
  final String tokenType;

  /// Vigencia en segundos.
  final int? expiresIn;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
