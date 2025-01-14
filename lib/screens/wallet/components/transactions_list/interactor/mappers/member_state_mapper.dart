import 'package:async/async.dart';
import 'package:seeds/domain-shared/page_state.dart';
import 'package:seeds/screens/wallet/components/transactions_list/interactor/viewmodels/member_state.dart';

class MemberStateMapper {
  MemberState mapResultToState(MemberState currentState, Result result) {
    return result.isError
        ? currentState.copyWith(pageState: PageState.failure)
        : currentState.copyWith(
            member: result.asValue?.value,
            pageState: PageState.success,
          );
  }
}
