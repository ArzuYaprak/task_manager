import 'package:easy_localization/easy_localization.dart';
import 'package:task_manager/exceptions/api_exception.dart';

extension ApiExceptionLocalization on ApiException {
  String localizedMessage() {
    return messageKey.tr(namedArgs: namedArgs);
  }
}
