import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/datasource/remote/model/transaction_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/screens/dashboard/components/transaction_info_card.dart';
import 'package:seeds/v2/screens/dashboard/interactor/viewmodels/bloc.dart';
import 'package:seeds/v2/screens/dashboard/interactor/viewmodels/transactions_list_bloc.dart';
import 'package:seeds/v2/screens/dashboard/interactor/viewmodels/transactions_list_events.dart';
import 'package:seeds/v2/screens/dashboard/interactor/viewmodels/transactions_list_state.dart';
import 'package:seeds/v2/screens/dashboard/interactor/viewmodels/wallet_bloc.dart';
import 'package:shimmer/shimmer.dart';

class TransactionsListWidget extends StatefulWidget {
  @override
  _TransactionsListWidgetState createState() => _TransactionsListWidgetState();
}

class _TransactionsListWidgetState extends State<TransactionsListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionsListBloc>(
      create: (_) => TransactionsListBloc()..add(LoadTransactionsListEvent()),
      child: BlocListener<WalletBloc, WalletState>(
          listenWhen: (context, state) => state.pageState == PageState.loading,
          listener: (context, state) {
            BlocProvider.of<TransactionsListBloc>(context).add(LoadTransactionsListEvent());
          },
          child: BlocBuilder<TransactionsListBloc, TransactionsListState>(
            builder: (context, state) {
              switch (state.pageState) {
                case PageState.loading:
                  return Column(
                    children: [
                      loadingShimmer(),
                      loadingShimmer(),
                      loadingShimmer(),
                      loadingShimmer(),
                      loadingShimmer(),
                    ],
                  );
                default:
                  if (state.pageState == PageState.success) {
                    print("tx ${state.transactions.length}");
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return buildTransaction(settingsStorage.accountName, state.transactions[index]);
                      //return ListTile(title: Text("TILE"));
                    },
                    itemCount: state.transactions.length,
                  );
              }
            },
          )),
    );
  }

  Widget buildTransaction(String userAccount, TransactionModel model) {
    String displayAccount = model.to == userAccount ? model.from : model.to;

    return TransactionInfoCard(
      callback: () {
        //onTransaction(transaction: model, member: member.data! as MemberModel, type: type);
      },
      profileAccount: displayAccount,
      profileNickname: "",
      profileImage: "",
      timestamp: model.timestamp,
      amount: model.quantity,
      incoming: userAccount == model.to,
    );
  }

  Widget loadingShimmer() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 44,
                //width: 300,
                color: Colors.black26,
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              ),
            ),
          ],
        ),
      );
}