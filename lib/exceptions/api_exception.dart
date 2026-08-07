class ApiException implements Exception {
  const ApiException({required this.messageKey, this.statusCode});

  final String messageKey;
  final int? statusCode;

  //burda namedArgs status alanını kolayca doldurmak için var
  Map<String, String> get namedArgs {
    if (statusCode == null) {
      return const {};
    }

    return {'status': statusCode.toString()};
  }
}
