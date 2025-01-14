import 'package:seeds/domain-shared/page_state.dart';
import 'package:seeds/domain-shared/result_to_state_mapper.dart';
import 'package:seeds/screens/transfer/receive/receive_detail_qr_code/interactor/viewmodels/receive_detail_arguments.dart';
import 'package:seeds/screens/transfer/receive/receive_enter_data/interactor/viewmodels/page_commands.dart';
import 'package:seeds/screens/transfer/receive/receive_enter_data/interactor/viewmodels/receive_enter_data_state.dart';

class CreateInvoiceResultMapper extends StateMapper {
  ReceiveEnterDataState mapResultToState(ReceiveEnterDataState currentState, Result result) {
    if (result.isError) {
      print('Error invoice hash not retrieved');
      return currentState.copyWith(pageState: PageState.success, pageCommand: ShowTransactionFail());
    } else {
      return currentState.copyWith(
        pageState: PageState.success,
        pageCommand: NavigateToReceiveDetails(
          receiveDetailArguments: ReceiveDetailArguments(
            fiatAmount: currentState.fiatAmount,
            invoiceLink: result.asValue!.value,
            tokenAmount: currentState.tokenAmount,
            description: currentState.description,
          ),
        ),
      );
    }
  }
}
