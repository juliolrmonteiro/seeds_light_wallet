import 'package:dart_esr/dart_esr.dart';

class SeedsESR {

  SigningRequestManager manager;

  List<Action> actions;

  SeedsESR({String uri}) {
    manager = TelosSigningManager.from(uri);
  }

  Future<void> resolve({String account}) async {
    this.actions = await manager.fetchActions(account: account);
  }

  Action firstAction() {
    return actions[0];
  }
}

extension TelosSigningManager on SigningRequestManager {
    static SigningRequestManager from(String uri) {
      return SigningRequestManager.from(uri,
      options:
          defaultSigningRequestEncodingOptions(nodeUrl: 'https://api.eos.miami'));
    }

    Future<List<Action>> fetchActions({String account, String permission = "active"}) async {

      var abis = await fetchAbis();

      var auth = Authorization();
      auth.actor = account;
      auth.permission = permission;

      var actions = resolveActions(abis, auth);

      //print("actions: "+actions.toString());
      //print("actions[0]: "+actions[0].toJson().toString());

      return actions;
    }
}