import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seeds/components/full_page_loading_indicator.dart';
import 'package:seeds/components/send_loading_indicator.dart';
import 'package:seeds/design/app_theme.dart';
import 'package:seeds/blocs/rates/viewmodels/bloc.dart';
import 'package:seeds/components/flat_button_long.dart';
import 'package:seeds/components/full_page_error_indicator.dart';
import 'package:seeds/domain-shared/page_state.dart';
import 'package:seeds/i18n/transfer/transfer.i18n.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/components/generic_transaction_success_diaog.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/components/send_transaction_success_dialog.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/components/transaction_details.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/send_confirmation_bloc.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/viewmodels/send_confirmation_arguments.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/viewmodels/send_confirmation_commands.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/viewmodels/send_confirmation_events.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/viewmodels/send_confirmation_state.dart';
import 'package:seeds/utils/cap_utils.dart';

/// SendConfirmation SCREEN
class SendConfirmationScreen extends StatelessWidget {
  const SendConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SendConfirmationArguments arguments =
        ModalRoute.of(context)!.settings.arguments! as SendConfirmationArguments;

    return BlocProvider(
      create: (_) => SendConfirmationBloc(arguments)..add(InitSendConfirmationWithArguments()),
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        )),
        body: BlocListener<SendConfirmationBloc, SendConfirmationState>(
          listenWhen: (_, current) => current.pageCommand != null,
          listener: (BuildContext context, SendConfirmationState state) {
            final pageCommand = state.pageCommand;
            if (pageCommand is ShowTransferSuccess) {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button
                builder: (BuildContext buildContext) => SendTransactionSuccessDialog.fromPageCommand(
                  onCloseButtonPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  pageCommand: pageCommand,
                ),
              );
            } else if (pageCommand is ShowTransactionSuccess) {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button
                builder: (BuildContext buildContext) => GenericTransactionSuccessDialog(
                  transaction: pageCommand.transactionModel,
                  onCloseButtonPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              );
            }
          },
          child: BlocBuilder<SendConfirmationBloc, SendConfirmationState>(
            builder: (context, SendConfirmationState state) {
              switch (state.pageState) {
                case PageState.initial:
                  return const SizedBox.shrink();
                case PageState.loading:
                  return state.isTransfer ? const SendLoadingIndicator() : const FullPageLoadingIndicator();
                case PageState.failure:
                  return const FullPageErrorIndicator();
                case PageState.success:
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: <Widget>[
                              TransactionDetails(
                                /// This needs to change to use the token icon. right now its hard coded to seeds
                                image: SvgPicture.asset("assets/images/seeds_logo.svg"),
                                title: state.actionName.inCaps,
                                beneficiary: state.account,
                              ),
                              const SizedBox(height: 42),
                              Column(
                                children: <Widget>[
                                  ...state.lineItems
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                e.label!,
                                                style: Theme.of(context).textTheme.subtitle2OpacityEmphasis,
                                              ),
                                              Text(e.text.toString(), style: Theme.of(context).textTheme.subtitle2),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FlatButtonLong(
                          title: 'Confirm and Send'.i18n,
                          onPressed: () {
                            final RatesState rates = BlocProvider.of<RatesBloc>(context).state;
                            BlocProvider.of<SendConfirmationBloc>(context).add(SendTransactionEvent(rates));
                          },
                        ),
                      ),
                    ],
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
