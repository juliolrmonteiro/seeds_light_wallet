import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeds/providers/notifiers/auth_notifier.dart';
import 'package:seeds/providers/notifiers/settings_notifier.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/components/full_page_error_indicator.dart';
import 'package:seeds/v2/components/full_page_loading_indicator.dart';
import 'package:seeds/v2/screens/pincode/components/create_passcode.dart';
import 'package:seeds/v2/screens/pincode/components/verify_passcode.dart';
import 'package:seeds/v2/screens/pincode/interactor/viewmodels/bloc.dart';

class PasscodeScreen extends StatelessWidget {
  const PasscodeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _securityBloc = ModalRoute.of(context).settings.arguments;
    return BlocProvider(
      create: (context) => PasscodeBloc(
          settingsNotifier: SettingsNotifier.of(context),
          authNotifier: AuthNotifier.of(context),
          securityBloc: _securityBloc)
        ..add(const DefineView()),
      child: BlocBuilder<PasscodeBloc, PasscodeState>(
        builder: (context, state) {
          switch (state.pageState) {
            case PageState.initial:
              return const SizedBox.shrink();
            case PageState.loading:
              return const FullPageLoadingIndicator();
            case PageState.failure:
              return const FullPageErrorIndicator();
            case PageState.success:
              return state.isCreateView ? const CreatePasscode() : const VerifyPasscode();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
