import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/screens/settings/sex_options.dart';
import 'package:nomdebebe/screens/settings/first_letters.dart';
import 'package:nomdebebe/screens/settings/decades.dart';
import 'package:nomdebebe/screens/settings/disliked_names.dart';
import 'package:nomdebebe/screens/settings/data_export.dart';
import 'package:nomdebebe/screens/settings/data_reset.dart';
import 'package:nomdebebe/screens/settings/theme_options.dart';
import 'package:nomdebebe/screens/settings/pink_and_blue.dart';
import 'package:nomdebebe/screens/settings/restore_purchases.dart';
import 'package:nomdebebe/screens/settings/about.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
      return ListView(children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child:
                Text("Filters", style: Theme.of(context).textTheme.headline5)),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(height: 0, thickness: 1)),
        SexOptions(),
        FirstLetterOptions(),
        DecadeOptions(),
        Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text("Data", style: Theme.of(context).textTheme.headline5)),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(height: 0, thickness: 1)),
        DislikedNames(),
        DataExport(),
        DataReset(),
        Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text("App", style: Theme.of(context).textTheme.headline5)),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(height: 0, thickness: 1)),
        ThemeOptions(),
        PinkAndBlue(),
        RestorePurchases(),
        About(),
      ]);
    });
  }
}
