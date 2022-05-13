import 'package:capstone/utilities/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'plan_trip_tap.dart';
import 'nearest_gas_tab.dart';
import 'vehicle_tab.dart';
import 'login.dart';

//Page creates tab bar and calls other screens based on what tab is open
class CapstoneApp extends StatelessWidget {
  const CapstoneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only allow app to work vertically
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return const CupertinoApp(
      //I was using cupertino and material widgets lol so I was getting localization issues
      //switch to just cupertino to get rid of this
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      home: Login(),
    );
  }
}

class CapstoneHomePage extends StatelessWidget {
  const CapstoneHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppState(),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.map),
                label: 'Plan Trip',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gauge),
                label: 'Nearest Gas',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.car_detailed),
                label: 'My Vehicles',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            late final CupertinoTabView returnValue;
            switch (index) {
              case 0:
                returnValue = CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(
                    child: PlanTripTab(),
                  );
                });
                break;
              case 1:
                returnValue = CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(
                    child: NearestGasTab(),
                  );
                });
                break;
              case 2:
                returnValue = CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(
                    child: VehicleTab(),
                  );
                });
                break;
            }
            return returnValue;
          },
        ));
  }
}
