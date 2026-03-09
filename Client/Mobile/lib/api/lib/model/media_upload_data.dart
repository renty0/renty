//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MediaUploadData {
  /// Returns a new [MediaUploadData] instance.
  MediaUploadData({
    this.id,
    this.url,
    this.fileName,
    this.extension_,
    this.contentType,
    this.fileType,
    this.sizeBytes,
    this.width,
    this.height,
    this.createdAt,
    this.entityId,
    this.entityType,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  String? url;

  String? fileName;

  String? extension_;

  String? contentType;

  String? fileType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sizeBytes;

  int? width;

  int? height;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  String? entityId;

  String? entityType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaUploadData &&
    other.id == id &&
    other.url == url &&
    other.fileName == fileName &&
    other.extension_ == extension_ &&
    other.contentType == contentType &&
    other.fileType == fileType &&
    other.sizeBytes == sizeBytes &&
    other.width == width &&
    other.height == height &&
    other.createdAt == createdAt &&
    other.entityId == entityId &&
    other.entityType == entityType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (url == null ? 0 : url!.hashCode) +
    (fileName == null ? 0 : fileName!.hashCode) +
    (extension_ == null ? 0 : extension_!.hashCode) +
    (contentType == null ? 0 : contentType!.hashCode) +
    (fileType == null ? 0 : fileType!.hashCode) +
    (sizeBytes == null ? 0 : sizeBytes!.hashCode) +
    (width == null ? 0 : width!.hashCode) +
    (height == null ? 0 : height!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (entityId == null ? 0 : entityId!.hashCode) +
    (entityType == null ? 0 : entityType!.hashCode);

  @override
  String toString() => 'MediaUploadData[id=$id, url=$url, fileName=$fileName, extension_=$extension_, contentType=$contentType, fileType=$fileType, sizeBytes=$sizeBytes, width=$width, height=$height, createdAt=$createdAt, entityId=$entityId, entityType=$entityType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    if (this.fileName != null) {
      json[r'fileName'] = this.fileName;
    } else {
      json[r'fileName'] = null;
    }
    if (this.extension_ != null) {
      json[r'extension'] = this.extension_;
    } else {
      json[r'extension'] = null;
    }
    if (this.contentType != null) {
      json[r'contentType'] = this.contentType;
    } else {
      json[r'contentType'] = null;
    }
    if (this.fileType != null) {
      json[r'fileType'] = this.fileType;
    } else {
      json[r'fileType'] = null;
    }
    if (this.sizeBytes != null) {
      json[r'sizeBytes'] = this.sizeBytes;
    } else {
      json[r'sizeBytes'] = null;
    }
    if (this.width != null) {
      json[r'width'] = this.width;
    } else {
      json[r'width'] = null;
    }
    if (this.height != null) {
      json[r'height'] = this.height;
    } else {
      json[r'height'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.entityId != null) {
      json[r'entityId'] = this.entityId;
    } else {
      json[r'entityId'] = null;
    }
    if (this.entityType != null) {
      json[r'entityType'] = this.entityType;
    } else {
      json[r'entityType'] = null;
    }
    return json;
  }

  /// Returns a new [MediaUploadData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaUploadData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaUploadData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MediaUploadData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MediaUploadData(
        id: mapValueOfType<String>(json, r'id'),
        url: mapValueOfType<String>(json, r'url'),
        fileName: mapValueOfType<String>(json, r'fileName'),
        extension_: mapValueOfType<String>(json, r'extension'),
        contentType: mapValueOfType<String>(json, r'contentType'),
        fileType: mapValueOfType<String>(json, r'fileType'),
        sizeBytes: mapValueOfType<int>(json, r'sizeBytes'),
        width: mapValueOfType<int>(json, r'width'),
        height: mapValueOfType<int>(json, r'height'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        entityId: mapValueOfType<String>(json, r'entityId'),
        entityType: mapValueOfType<String>(json, r'entityType'),
      );
    }
    return null;
  }

  static List<MediaUploadData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaUploadData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaUploadData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaUploadData> mapFromJson(dynamic json) {
    final map = <String, MediaUploadData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaUploadData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaUploadData-objects as value to a dart map
  static Map<String, List<MediaUploadData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaUploadData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaUploadData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

