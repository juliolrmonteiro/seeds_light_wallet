import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeds/components/search_user/components/search_result_list.dart';
import 'package:seeds/components/search_user/interactor/search_user_bloc.dart';
import 'package:seeds/components/search_user/interactor/viewmodels/search_user_events.dart';
import 'package:seeds/components/search_user/interactor/viewmodels/search_user_state.dart';
import 'package:seeds/constants/app_colors.dart';
import 'package:seeds/datasource/remote/model/member_model.dart';
import 'package:seeds/domain-shared/page_state.dart';
import 'package:seeds/domain-shared/ui_constants.dart';
import 'package:seeds/i18n/components/components.i18n.dart';

class SearchUser extends StatelessWidget {
  final ValueSetter<MemberModel> resultCallBack;
  final List<String>? noShowUsers;
  final _controller = TextEditingController();
  final _searchBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: AppColors.darkGreen2, width: 2.0),
  );

  SearchUser({Key? key, required this.resultCallBack, this.noShowUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchUserBloc>(
      create: (_) => SearchUserBloc(noShowUsers),
      child: BlocBuilder<SearchUserBloc, SearchUserState>(
        builder: (context, SearchUserState state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: horizontalEdgePadding, left: horizontalEdgePadding, top: 10),
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  onChanged: (String value) {
                    BlocProvider.of<SearchUserBloc>(context).add(OnSearchChange(searchQuery: value));
                  },
                  decoration: InputDecoration(
                      suffixIcon: state.pageState == PageState.loading
                          ? Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.green)),
                            )
                          : IconButton(
                              icon: Icon(
                                state.searchBarIcon,
                                color: AppColors.white,
                                size: 26,
                              ),
                              onPressed: () {
                                if (state.searchBarIcon == Icons.clear) {
                                  BlocProvider.of<SearchUserBloc>(context).add(ClearIconTapped());
                                  _controller.clear();
                                }
                              }),
                      enabledBorder: _searchBorder,
                      focusedBorder: _searchBorder,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      hintText: 'Search...'.i18n),
                ),
              ),
              const SizedBox(height: 16),
              searchResults(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget searchResults(BuildContext context, SearchUserState state) {
    switch (state.pageState) {
      case PageState.initial:
        return const SizedBox.shrink();
      case PageState.loading:
        return SearchUsersList(resultCallBack: resultCallBack);
      case PageState.failure:
        return SearchUsersList(resultCallBack: resultCallBack);
      case PageState.success:
        if (state.users.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("No users found.".i18n)),
          );
        } else {
          return SearchUsersList(resultCallBack: resultCallBack);
        }
    }
  }
}
