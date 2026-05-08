/// Model for app version information from server
class AppVersionModel {
  final String version;
  final String url;
  final String? description;
  final bool forceUpdate;
  final int buildNumber;

  const AppVersionModel({
    required this.version,
    required this.url,
    this.description,
    this.forceUpdate = false,
    required this.buildNumber,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      version: json['version'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      forceUpdate: json['force_update'] as bool? ?? false,
      buildNumber: json['build_number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'url': url,
      'description': description,
      'force_update': forceUpdate,
      'build_number': buildNumber,
    };
  }

  @override
  String toString() {
    return 'AppVersionModel(version: $version, url: $url, buildNumber: $buildNumber)';
  }
}