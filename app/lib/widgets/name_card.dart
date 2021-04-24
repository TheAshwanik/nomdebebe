import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/blocs/settings/settings.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomdebebe/screens/name_details_screen.dart';

class NameCard extends StatelessWidget {
  final Name name;

  const NameCard(this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NamesBloc, NamesState>(
        builder: (BuildContext context, NamesState state) {
      return Dismissible(
          key: Key(name.id.toString()),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              BlocProvider.of<NamesBloc>(context).add(NamesLike(name));
            } else {
              BlocProvider.of<NamesBloc>(context).add(NamesDislike(name));
            }
          },
          resizeDuration: null,
          background: Container(
              child: Icon(FontAwesomeIcons.solidHeart,
                  size: 128, color: Colors.white)),
          secondaryBackground: Container(
              child: Icon(FontAwesomeIcons.solidThumbsDown,
                  size: 128, color: Colors.white)),
          child: Hero(
              tag: "nameDetailsHero_" + name.id.toString(),
              child: Card(
                  color: Colors.transparent,
                  elevation: Theme.of(context).brightness == Brightness.dark
                      ? 0
                      : null,
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (BuildContext context, SettingsState state) =>
                          Container(
                              decoration: BoxDecoration(
                                  color: sexToColour(
                                      context, name.sex, state.pinkAndBlue),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Stack(
                                  alignment: Alignment.center,
                                  fit: StackFit.loose,
                                  children: [
                                    Column(
                                      children: <Widget>[
                                        AspectRatio(
                                            aspectRatio: 1,
                                            child: Container(
                                                child: Center(
                                                    child: Text(name.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline3!
                                                            .copyWith(
                                                                color: Colors
                                                                    .white)))))
                                      ],
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                          icon: Icon(FontAwesomeIcons.chartLine,
                                              color: Colors.white),
                                          onPressed: () => Navigator.of(context)
                                              .push(MaterialPageRoute<void>(
                                                  builder:
                                                      (BuildContext context) =>
                                                          NameDetailsScreen(
                                                              name)))),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: IconButton(
                                          icon: Icon(
                                              FontAwesomeIcons.solidThumbsDown,
                                              color: Colors.white),
                                          onPressed: () =>
                                              BlocProvider.of<NamesBloc>(
                                                      context)
                                                  .add(NamesDislike(name))),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: IconButton(
                                          icon: Icon(
                                              FontAwesomeIcons.solidHeart,
                                              color: Colors.white),
                                          onPressed: () =>
                                              BlocProvider.of<NamesBloc>(
                                                      context)
                                                  .add(NamesLike(name))),
                                    ),
                                  ]))))));
    });
  }
}
