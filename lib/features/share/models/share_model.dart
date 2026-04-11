class ShareModel {
  final String id;
  final String code;
  final String fileUrl;
  final String fileName;
  final DateTime createdAt;

  const ShareModel({
    required this.id,
    required this.code,
    required this.fileUrl,
    required this.fileName,
    required this.createdAt,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] as String,
      code: json['code'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'file_url': fileUrl,
    'file_name': fileName,
    'created_at': createdAt.toIso8601String(),
  };
}