import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:seeds/datasource/remote/model/generic_transaction_model.dart';
import 'package:seeds/design/app_theme.dart';
import 'package:seeds/components/custom_dialog.dart';
import 'package:seeds/constants/app_colors.dart';
import 'package:seeds/i18n/transfer/transfer.i18n.dart';

class GenericTransactionSuccessDialog extends StatelessWidget {
  final GenericTransactionModel transaction;
  final VoidCallback onCloseButtonPressed;

  const GenericTransactionSuccessDialog({
    Key? key,
    required this.transaction,
    required this.onCloseButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: CustomDialog(
          icon: SvgPicture.asset('assets/images/security/success_outlined_icon.svg'),
          onSingleLargeButtonPressed: onCloseButtonPressed,
          singleLargeButtonTitle: 'Close'.i18n,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(transaction.action, style: Theme.of(context).textTheme.headline4),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 4),
                  child: Text(transaction.account, style: Theme.of(context).textTheme.subtitle2),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Column(
              children: <Widget>[
                ...transaction.lineItems
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
            const SizedBox(height: 30.0),
            Row(
              children: [
                Text('Date:  '.i18n, style: Theme.of(context).textTheme.subtitle2),
                const SizedBox(width: 16),
                Text(
                  DateFormat('dd MMMM yyyy HH:mm').format(transaction.timestamp?.toLocal() ?? DateTime.now()),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            Row(
              children: [
                Text('Transaction ID:  '.i18n, style: Theme.of(context).textTheme.subtitle2),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    transaction.transactionId ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  color: AppColors.lightGreen6,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: transaction.transactionId ?? "No transaction ID")).then(
                      (_) {
                        ScaffoldMessenger.maybeOf(context)!
                            .showSnackBar(SnackBar(content: Text("Copied".i18n), duration: const Duration(seconds: 1)));
                      },
                    );
                  },
                )
              ],
            ),
            Row(
              children: [
                Text('Status:  '.i18n, style: Theme.of(context).textTheme.subtitle2),
                const SizedBox(width: 16),
                Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)), color: AppColors.lightGreen6),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8),
                    child: Text(
                      "Successful".i18n,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
