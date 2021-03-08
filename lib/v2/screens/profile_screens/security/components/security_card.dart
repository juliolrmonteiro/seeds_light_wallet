import 'package:flutter/material.dart';
import 'package:seeds/constants/app_colors.dart';
import 'package:seeds/v2/components/divider_jungle.dart';
import 'package:seeds/v2/domain-shared/ui_constants.dart';

/// SETTINGS CARD
class SecurityCard extends StatelessWidget {
  /// Card icon
  final Widget icon;

  /// The text title in the first row
  final String title;

  /// The descrption text in the second row
  final String description;

  /// The widget in the right side of the title
  final Widget titleWidget;

  final GestureTapCallback onTap;

  const SecurityCard({
    Key key,
    @required this.icon,
    @required this.title,
    this.description = '',
    this.titleWidget,
    this.onTap,
  })  : assert(icon != null),
        assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightGreen2,
            borderRadius: BorderRadius.circular(defaultCardBorderRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0),
                    child: icon,
                  ),
                ],
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 10.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.button,
                              ),
                            ),
                            if (titleWidget != null) titleWidget,
                          ],
                        ),
                      ),
                      const DividerJungle(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                description,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}