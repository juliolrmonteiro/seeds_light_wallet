import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/datasource/remote/model/balance_model.dart';
import 'package:seeds/v2/datasource/remote/model/token_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/domain-shared/result_to_state_mapper.dart';
import 'package:seeds/v2/screens/wallet/components/tokens_cards/interactor/viewmodels/token_balance_view_model.dart';
import 'package:seeds/v2/screens/wallet/components/tokens_cards/interactor/viewmodels/token_balances_state.dart';

class TokenBalancesStateMapper {
  TokenBalancesState mapResultToState(TokenBalancesState currentState, List<TokenModel> tokens, List<Result> results) {
    assert(tokens.length == results.length, "invalid results");

    final List<TokenBalanceViewModel> available = [];

    final Iterable<TokenModel> whitelist =
        TokenModel.AllTokens.where((element) => settingsStorage.tokensWhitelist.contains(element.id));

    final List<TokenModel> blacklist = []; // user has chosen to hide this token

    final List<String> newWhitelist = [];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final result = results[i];
      final bool whitelisted = whitelist.contains(token);
      if (whitelisted || !blacklist.contains(token)) {
        if (results[i].isError) {
          print("error loading ${token.symbol} - show existing balance.");
          final existingBalance = currentState.balanceViewModelForToken(token.id);
          if (existingBalance != null || whitelisted) {
            final viewModel = existingBalance ?? TokenBalanceViewModel(token, null, errorLoading: true);
            available.add(viewModel);
            newWhitelist.add(token.id);
          }
        } else {
          final BalanceModel balance = result.asValue?.value as BalanceModel;
          if (whitelisted || balance.quantity > 0) {
            available.add(TokenBalanceViewModel(token, balance));
            newWhitelist.add(token.id);
          }
        }
      }
    }

    settingsStorage.tokensWhitelist = newWhitelist;

    return currentState.copyWith(pageState: PageState.success, availableTokens: available);
  }
}
