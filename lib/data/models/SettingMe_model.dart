class CompanyResponse {
  final bool success;
  final CompanyData? data;

  CompanyResponse({
    required this.success,
    this.data,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? CompanyData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class CompanyData {
  final String id;
  final String name;
  final String clientCode;
  final String slug;
  final String status;
  final double? officeLat;
  final double? officeLng;
  final double? geoFenceRadiusMeters;
  final int lateAfterMinutes;
  final String createdAt;
  final String updatedAt;

  CompanyData({
    required this.id,
    required this.name,
    required this.clientCode,
    required this.slug,
    required this.status,
    this.officeLat,
    this.officeLng,
    this.geoFenceRadiusMeters,
    required this.lateAfterMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      clientCode: json['clientCode'] ?? '',
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      officeLat: json['officeLat'] != null
          ? (json['officeLat'] as num).toDouble()
          : null,
      officeLng: json['officeLng'] != null
          ? (json['officeLng'] as num).toDouble()
          : null,
      geoFenceRadiusMeters: json['geoFenceRadiusMeters'] != null
          ? (json['geoFenceRadiusMeters'] as num).toDouble()
          : null,
      lateAfterMinutes: json['lateAfterMinutes'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clientCode': clientCode,
      'slug': slug,
      'status': status,
      'officeLat': officeLat,
      'officeLng': officeLng,
      'geoFenceRadiusMeters': geoFenceRadiusMeters,
      'lateAfterMinutes': lateAfterMinutes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}