import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/account.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:vitalitas/ui/appstate/bot.dart';
import 'package:vitalitas/ui/appstate/health.dart';
import 'package:vitalitas/ui/appstate/healthdex.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeAppState extends AppState {
  @override
  Widget? getBody(State state) {
    return Container(
      child: Text('Home'),
    );
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.home_outlined,
        text: 'Home',
        iconActiveColor:
            HSLColor.fromColor(Vitalitas.theme.fg).withLightness(0.2).toColor(),
        backgroundColor: Vitalitas.theme.fg,
        iconColor: Vitalitas.theme.bg);
  }
}

class HomeState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    List<AppState> appStates = [];
    appStates.add(HomeAppState());
    appStates.add(HealthAppState());
    appStates.add(HealthdexAppState());
    appStates.add(AccountAppState());
    appStates.add(BotAppState());

    List<GButton> gButtons = [];
    for (AppState state in appStates) {
      gButtons.add(state.getNavButton());
    }

    return Scaffold(
      body: appStates[_index].getBody(this),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Vitalitas.theme.acc,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
              ]),
          child: SafeArea(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: GNav(
                    gap: 8,
                    textStyle: const TextStyle(fontFamily: 'Comfort'),
                    iconSize: 24,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    selectedIndex: _index,
                    rippleColor: Vitalitas.theme.acc,
                    hoverColor: Vitalitas.theme.acc,
                    tabBackgroundColor: Vitalitas.theme.acc,
                    padding: EdgeInsets.all(16),
                    tabs: gButtons,
                    onTabChange: (index) {
                      setState(() {
                        _index = index;
                      });
                    },
                  )))),
    );
  }
}
