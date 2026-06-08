class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final String message;
  final String studentName;
  final String nis;
  final String date;
  final String time;
  final String status;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    required this.message,
    this.studentName = '',
    this.nis = '',
    this.date = '',
    this.time = '',
    this.status = '',
  });
}
