import 'package:async/async.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:eosdart/eosdart.dart';
import 'package:seeds/datasource/remote/api/eos_repository.dart';

class SendTransactionRepository extends EosRepository {
  Future<Result> sendTransaction({
    required String actionName,
    required String account,
    required Map<String, dynamic> data,
    required String accountName,
  }) async {
    final actions = [
      Action()
        ..account = account
        ..name = actionName
        ..data = data
    ];
    for (final action in actions) {
      action.authorization = [
        Authorization()
          ..actor = accountName
          ..permission = permissionActive
      ];
    }

    print("[eos] send transaction ${actions[0].toString()}");

    final transaction = buildFreeTransaction(actions, accountName);

    return buildEosClient()
        .pushTransaction(transaction)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return response["transaction_id"];
            }))
        .catchError((error) => mapEosError(error));
  }
}
