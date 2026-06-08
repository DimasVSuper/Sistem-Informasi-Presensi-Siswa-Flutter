class AttendanceLog {
  final String qrCode;
  final String studentName;
  final String nis;
  final DateTime scannedAt;
  final bool isSuccess;
  final String status; // 'Hadir', 'Sudah Hadir', 'Tidak Dikenal', 'Error Koneksi', dll.
  final String message;

  AttendanceLog({
    required this.qrCode,
    required this.studentName,
    required this.nis,
    required this.scannedAt,
    required this.isSuccess,
    required this.status,
    required this.message,
  });

  // Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'qrCode': qrCode,
      'studentName': studentName,
      'nis': nis,
      'scannedAt': scannedAt.toIso8601String(),
      'isSuccess': isSuccess,
      'status': status,
      'message': message,
    };
  }

  // Create from JSON Map
  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      qrCode: json['qrCode'] ?? '',
      studentName: json['studentName'] ?? '',
      nis: json['nis'] ?? '',
      scannedAt: json['scannedAt'] != null 
          ? DateTime.parse(json['scannedAt']) 
          : DateTime.now(),
      isSuccess: json['isSuccess'] ?? false,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
