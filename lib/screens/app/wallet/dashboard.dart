import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeds/constants/app_colors.dart';
import 'package:seeds/features/backup/backup_service.dart';
import 'package:seeds/models/models.dart';
import 'package:seeds/providers/notifiers/balance_notifier.dart';
import 'package:seeds/providers/notifiers/members_notifier.dart';
import 'package:seeds/providers/notifiers/rate_notiffier.dart';
import 'package:seeds/providers/notifiers/settings_notifier.dart';
import 'package:seeds/providers/notifiers/tokens_notifier.dart';
import 'package:seeds/providers/notifiers/transactions_notifier.dart';
import 'package:seeds/providers/services/navigation_service.dart';
import 'package:seeds/utils/string_extension.dart';
import 'package:seeds/widgets/empty_button.dart';
import 'package:seeds/widgets/main_card.dart';
import 'package:seeds/widgets/transaction_avatar.dart';
import 'package:seeds/widgets/transaction_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:seeds/i18n/wallet.i18n.dart';

enum TransactionType { income, outcome }

class Dashboard extends StatefulWidget {
  Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  get tokenSymbol => SettingsNotifier.of(context).tokenSymbol;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // return ChooseTokenSheet();

    return RefreshIndicator(
      child: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.fromLTRB(17, 0, 17, 17),
            child: Column(
              children: <Widget>[
                // buildNotification(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildHeader(),
                    // alternatively show slider cards with all available tokens
                    // show the same background color as modal and allow to click at all rectangle
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.swap_calls,
                          color: AppColors.blue,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            builder: (BuildContext context) {
                              // show separate card for each token
                              return ChooseTokenSheet();
                            },
                          );

                          // showModalBottomSheet(
                          //   (context) => Container(
                          //     width: MediaQuery.of(context).size.width,
                          //     height: 250,
                          //     color: Colors.black,
                          //     child: Column(
                          //       children: [
                          //         // show all tokens you have on balance and allow to create your own
                          //         // actually even better just show personal token as existing and allow to
                          //         Text('Your Tokens')
                          //       ],
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
                buildTransactions(),
              ],
            )),
      ),
      onRefresh: refreshData,
    );
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   refreshData();
  // }

  Future<void> refreshData() async {
    await Future.wait(<Future<dynamic>>[
      TransactionsNotifier.of(context).fetchTransactionsCache(),
      TransactionsNotifier.of(context).refreshTransactions(),
      BalanceNotifier.of(context).fetchBalance(),
      RateNotifier.of(context).fetchRate(),
    ]);
  }

  void onTransfer() {
    NavigationService.of(context).navigateTo(Routes.transfer);
  }

  void onReceive() {
    NavigationService.of(context).navigateTo(Routes.receive);
  }

  Widget buildHeader() {
    final double width = MediaQuery.of(context).size.width * 0.84;
    final height = MediaQuery.of(context).size.height;
    final double textScaleFactor = width >= 320 ? 1.0 : 0.8;

    return Container(
      width: width,
      height: height * 0.25,
      child: MainCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: AppColors.gradient,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'Available balance'.i18n,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
              ),
              Consumer<BalanceNotifier>(builder: (context, model, child) {
                return (model != null && model.balance != null)
                    ? Column(
                        children: <Widget>[
                          Text(
                            model.balance.error
                                ? 'Network error'.i18n
                                : '${model.balance?.quantity?.seedsFormatted} $tokenSymbol',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w700),
                          ),
                          // Text(
                          //   "${(model.balance.numericQuantity / 15000).toStringAsFixed(2)} USD",
                          //   style: TextStyle(
                          //       color: Colors.white70,
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.w300),
                          // ),
                          Consumer<RateNotifier>(
                              builder: (context, rateModel, child) {
                            return Text(
                              model.balance.error
                                  ? 'Pull to update'.i18n
                                  : rateModel.rate == null
                                      ? ""
                                      : rateModel.rate.error
                                          ? "Exchange rate load error".i18n
                                          : '${rateModel.rate?.usdString(model.balance.numericQuantity)}',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300),
                            );
                          })
                        ],
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.green[300],
                        highlightColor: Colors.blue[300],
                        child: Container(
                          width: 200.0,
                          height: 26,
                          color: Colors.white,
                        ),
                      );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  EmptyButton(
                    width: width * 0.33,
                    title: 'Send'.i18n,
                    color: Colors.white,
                    onPressed: onTransfer,
                    textScaleFactor: textScaleFactor,
                  ),
                  EmptyButton(
                    width: width * 0.33,
                    title: 'Receive'.i18n,
                    color: Colors.white,
                    onPressed: onReceive,
                    textScaleFactor: textScaleFactor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotification() {
    final width = MediaQuery.of(context).size.width;

    final SettingsNotifier settings = SettingsNotifier.of(context);
    final backupService = Provider.of<BackupService>(context);

    if (backupService.showReminder) {
      return Consumer<BalanceNotifier>(builder: (context, model, child) {
        if (model != null &&
            model.balance != null &&
            model.balance.numericQuantity >=
                BackupService.BACKUP_REMINDER_MIN_AMOUNT) {
          return Container(
            width: width,
            child: MainCard(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      'Your private key has not been backed up!'.i18n,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EmptyButton(
                            width: width * 0.35,
                            title: 'Backup'.i18n,
                            color: Colors.white,
                            onPressed: () {
                              backupService.backup();
                            },
                          ),
                          EmptyButton(
                            width: width * 0.35,
                            title: 'Later'.i18n,
                            color: Colors.white,
                            onPressed: () {
                              settings.updateBackupLater();
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      });
    } else {
      return Container();
    }
  }

  void onTransaction({
    TransactionModel transaction,
    MemberModel member,
    TransactionType type,
  }) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (BuildContext context) {
          return TransactionDialog(
            transaction: transaction,
            member: member,
            transactionType: type,
          );
        });
  }

  Widget buildTransaction(TransactionModel model) {
    String userAccount = SettingsNotifier.of(context).accountName;

    TransactionType type = model.to == userAccount
        ? TransactionType.income
        : TransactionType.outcome;

    String participantAccountName =
        type == TransactionType.income ? model.from : model.to;

    return FutureBuilder(
      future:
          MembersNotifier.of(context).getAccountDetails(participantAccountName),
      builder: (ctx, member) => member.hasData
          ? InkWell(
              onTap: () => onTransaction(
                  transaction: model, member: member.data, type: type),
              child: Column(
                children: [
                  Divider(height: 22),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 12, right: 10),
                              child: Icon(
                                type == TransactionType.income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: type == TransactionType.income
                                    ? AppColors.green
                                    : AppColors.red,
                              ),
                            ),
                            TransactionAvatar(
                              size: 40,
                              account: member.data.account,
                              nickname: member.data.nickname,
                              image: member.data.image,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.blue,
                              ),
                            ),
                            Flexible(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              member.data.nickname,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              member.data.account,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: AppColors.grey,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ])))
                          ],
                        )),
                        Container(
                            margin: EdgeInsets.only(left: 10, right: 15),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  type == TransactionType.income ? '+ ' : '-',
                                  style: TextStyle(
                                      color: type == TransactionType.income
                                          ? AppColors.green
                                          : AppColors.red,
                                      fontSize: 16),
                                ),
                                Text(
                                  model.quantity,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 16,
                    width: 320,
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 10, right: 10),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTransactions() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: EdgeInsets.only(bottom: 7, top: 15),
      child: MainCard(
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: 3, left: 15, right: 15),
                child: Text(
                  'Latest transactions'.i18n,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
            Consumer<TransactionsNotifier>(
              builder: (context, model, child) =>
                  model != null && model.transactions != null
                      ? Column(
                          children: <Widget>[
                            ...model.transactions.map((trx) {
                              return buildTransaction(trx);
                            }).toList()
                          ],
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                height: 16,
                                width: 300,
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 10, right: 10),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChooseTokenSheet extends StatefulWidget {
  @override
  _ChooseTokenSheetState createState() => _ChooseTokenSheetState();
}

class _ChooseTokenSheetState extends State<ChooseTokenSheet> {
  @override
  void initState() {
    TokensNotifier.of(context).fetchTokens();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.gradient),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          height: 60,
          padding: EdgeInsets.only(top: 20, left: 20),
          child: Text(
            "Available Tokens",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Consumer<TokensNotifier>(
          builder: (context, tokensNotifier, child) {
            final tokens = tokensNotifier.tokens;

            return tokens.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: tokens.length,
                    itemBuilder: (context, index) => ListTile(
                        title: Text('${tokens[index].symbol} token'),
                        subtitle: Text('issued by ${tokens[index].issuer}'),
                        trailing: Text('${tokens[index].balance ?? ''}'),
                        onTap: () {
                          SettingsNotifier.of(context).saveCurrentToken(
                            tokenContract: tokens[index].contract,
                            tokenSymbol: tokens[index].symbol,
                          );
                        }),
                  )
                : Center(
                    child: LinearProgressIndicator(),
                  );
          },
        ),
      ],
    );
  }
}
