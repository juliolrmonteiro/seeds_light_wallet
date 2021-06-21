import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeds/i18n/edit_name.i18n.dart';
import 'package:seeds/utils/string_extension.dart';
import 'package:seeds/v2/components/flat_button_long.dart';
import 'package:seeds/v2/components/quadstate_clipboard_icon_button.dart';
import 'package:seeds/v2/components/text_form_field_custom.dart';
import 'package:seeds/v2/design/app_theme.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/screens/sign_up/viewmodels/bloc.dart';
import 'package:seeds/v2/screens/sign_up/viewmodels/states/create_username_state.dart';

class CreateUsername extends StatefulWidget {
  const CreateUsername({Key? key}) : super(key: key);

  @override
  _CreateUsernameState createState() => _CreateUsernameState();
}

class _CreateUsernameState extends State<CreateUsername> {
  late SignupBloc _bloc;
  final TextEditingController _keyController = TextEditingController();
  final _usernameFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SignupBloc>(context);
    if (_bloc.state.createUsernameState.username != null) {
      _keyController.text = _bloc.state.createUsernameState.username!;
    } else {
      _bloc.add(OnGenerateNewUsername(fullname: _bloc.state.displayNameState.displayName!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _navigateBack,
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state.createUsernameState.pageState == PageState.initial &&
                state.createUsernameState.pageCommand is UsernameGenerated) {
              _keyController.text = state.createUsernameState.username ?? _keyController.text;
              _bloc.add(OnUsernameChanged(username: state.createUsernameState.username!));
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Form(
                    key: _usernameFormKey,
                    child: TextFormFieldCustom(
                      maxLength: 12,
                      labelText: "Username".i18n,
                      controller: _keyController,
                      errorText: _bloc.state.createUsernameState.errorMessage,
                      suffixIcon: QuadStateClipboardIconButton(
                        isChecked: state.createUsernameState.isUsernameValid,
                        onClear: () {
                          _keyController.clear();
                        },
                        isLoading: state.createUsernameState.pageState == PageState.loading,
                        canClear: _keyController.text.isNotEmpty,
                      ),
                      onChanged: _onUsernameChanged,
                      validator: _validateUsername,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Text(
                      "Note: Usernames must be 12 characters long. "
                      "\n\n Usernames can only contain characters a-z  (all lowercase), 1 - 5 (no 0’s), and no special characters or full stops. "
                      "\n\n **Reminder! Your account name cannot be changed or deleted and will be public for other users to see.**",
                      style: Theme.of(context).textTheme.subtitle2OpacityEmphasis,
                    ),
                  ),
                  FlatButtonLong(
                    title: 'Next'.i18n,
                    onPressed: _onNextPressed(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateUsername(String? username) {
    final validCharacters = RegExp(r'^[a-z1-5]+$');

    if (username.isNullOrEmpty) {
      return 'Please select a username';
    } else if (RegExp(r'0|6|7|8|9').allMatches(username!).isNotEmpty) {
      return 'Only numbers 1-5 can be used.';
    } else if (username.toLowerCase() != username) {
      return "Name can be lowercase only";
    } else if (!validCharacters.hasMatch(username) || username.contains(' ')) {
      return "No special characters or spaces can be used";
    } else if (username.length != 12) {
      return 'Username must be 12 characters long';
    }

    return null;
  }

  void _onUsernameChanged(String text) {
    // This is to update the next button when we go from valid username to invalid
    setState(() {
      if (_usernameFormKey.currentState!.validate()) {
        _bloc.add(OnUsernameChanged(username: text));
      }
    });
  }

  VoidCallback? _onNextPressed() =>
      _bloc.state.createUsernameState.isUsernameValid && _usernameFormKey.currentState!.validate()
          ? () {
              FocusScope.of(context).unfocus();
              _bloc.add(CreateUsernameOnNextTapped());
            }
          : null;

  Future<bool> _navigateBack() {
    _bloc.add(OnBackPressed());
    return Future.value(false);
  }
}
