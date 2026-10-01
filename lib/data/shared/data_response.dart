class DataResponse<TModel> {
  bool? isSuccess;
  String? error;
  String? message;
  TModel? data;

  DataResponse({
    this.isSuccess,
    this.error,
    this.message,
    this.data,
  });

  factory DataResponse.fromJson(
    Map<String, dynamic> json,
    TModel Function(dynamic json)? fromJsonT,
  ) {
    final statusVal = json['status'];
    final bool statusSuccess = statusVal == true ||
        statusVal == 'success' ||
        statusVal == 1 ||
        statusVal == 200 ||
        statusVal == 201 ||
        statusVal == '200' ||
        statusVal == '201' ||
        statusVal == 'true';

    return DataResponse<TModel>(
      isSuccess: json['success'] ?? json['isSuccess'] ?? (statusVal != null ? statusSuccess : false),
      error: json['error']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : (json['data'] as TModel?),
    );
  }

  Map<String, dynamic> toJson([dynamic Function(TModel value)? toJsonT]) {
    return {
      'success': isSuccess,
      'message': message,
      if (error != null) 'error': error,
      if (data != null && toJsonT != null)
        'data': toJsonT(data as TModel)
      else if (data != null)
        'data': data,
    };
  }
}
