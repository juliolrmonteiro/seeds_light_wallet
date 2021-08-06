import 'package:flutter/material.dart';
import 'package:seeds/i18n/profile.i18n.dart';
import 'package:seeds/v2/components/custom_dialog.dart';
import 'package:seeds/v2/components/flat_button_long.dart';
import 'package:seeds/v2/design/app_theme.dart';

class CitizenshipUpgradeSuccessDialog extends StatelessWidget {
  final bool isResident;

  const CitizenshipUpgradeSuccessDialog({Key? key, required this.isResident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      icon: const Image(image: AssetImage("assets/images/profile/celebration_icon.png")),
      children: [
        Text('Congratulations!', style: Theme.of(context).textTheme.button1),
        const SizedBox(height: 30.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              isResident
                  ? RichText(
                      text: TextSpan(
                          text: 'You have have fulfilled all the requirements and are now officially upgraded to be a ',
                          style: Theme.of(context).textTheme.subtitle2,
                          children: <TextSpan>[
                            TextSpan(
                              text: "Citizen",
                              style: Theme.of(context).textTheme.subtitle2HighEmphasisGreen1,
                            ),
                            TextSpan(
                              text:
                                  '! You now have the ability to vote on proposals! Go to the Explore section to see more.',
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ]),
                      textAlign: TextAlign.center,
                    )
                  : RichText(
                      text: TextSpan(
                          text: 'You have have fulfilled all the requirements and are now officially upgraded to be a ',
                          style: Theme.of(context).textTheme.subtitle2,
                          children: <TextSpan>[
                            TextSpan(
                              text: "Resident",
                              style: Theme.of(context).textTheme.subtitle2HighEmphasisGreen1,
                            ),
                            TextSpan(
                              text: '! Just one more level until you are a full-fledged Citizen.',
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ]),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 36.0),
              FlatButtonLong(title: 'Done'.i18n, onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ],
    );
  }
}