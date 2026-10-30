class PunchResponse {
  final bool success;
  final PunchData? data;

  PunchResponse({
    required this.success,
    this.data,
  });

  factory PunchResponse.fromJson(Map<String, dynamic> json) {
    return PunchResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? PunchData.fromJson(json['data'])
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

class PunchData {
  final String id;
  final String date;
  final String? checkInAt;
  final String? checkOutAt;
  final double checkInLat;
  final double checkInLng;
  final double checkOutLat;
  final double checkOutLng;
  final String punchSource;
  final double checkInFaceScore;
  final double checkOutFaceScore;
  final String status;
  final String employeeId;

  PunchData({
    required this.id,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkOutLat,
    required this.checkOutLng,
    required this.punchSource,
    required this.checkInFaceScore,
    required this.checkOutFaceScore,
    required this.status,
    required this.employeeId,
  });

  factory PunchData.fromJson(Map<String, dynamic> json) {
    return PunchData(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      checkInAt: json['checkInAt'],
      checkOutAt: json['checkOutAt'],
      checkInLat: (json['checkInLat'] ?? 0).toDouble(),
      checkInLng: (json['checkInLng'] ?? 0).toDouble(),
      checkOutLat: (json['checkOutLat'] ?? 0).toDouble(),
      checkOutLng: (json['checkOutLng'] ?? 0).toDouble(),
      punchSource: json['punchSource'] ?? '',
      checkInFaceScore: (json['checkInFaceScore'] ?? 0).toDouble(),
      checkOutFaceScore: (json['checkOutFaceScore'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      employeeId: json['employeeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'checkInAt': checkInAt,
      'checkOutAt': checkOutAt,
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
      'punchSource': punchSource,
      'checkInFaceScore': checkInFaceScore,
      'checkOutFaceScore': checkOutFaceScore,
      'status': status,
      'employeeId': employeeId,
    };
  }
}