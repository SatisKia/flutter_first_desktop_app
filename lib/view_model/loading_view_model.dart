import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import '../main.dart';
import '../model.dart';
import '../view/loading_view.dart';

class MyLoadingWidget extends StatefulWidget {
  const MyLoadingWidget({Key? key}) : super(key: key);

  @override
  State createState() => MyLoadingState();
}

class MyLoadingState extends MyState {
  MyLoadingState() : super( LoadingView() );

  @override
  void onEnter() async {
    debugPrint( 'loading onEnter' );

    Locale locale = Localizations.localeOf( context );

    setWindowTitle(locale.languageCode == 'en' ? 'Calculator' : '電卓');

    final SystemTray systemTray = SystemTray();
    final AppWindow appWindow = AppWindow();

    await systemTray.initSystemTray(
      title: Platform.isWindows ? (locale.languageCode == 'en' ? 'Calculator' : '電卓') : '',
      iconPath: Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
    );

    // トレイアイコンにメニューを設定
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemCheckbox(
        label: locale.languageCode == 'en' ? 'Always on top' : '常に手前に表示',
        checked: await windowManager.isAlwaysOnTop(),
        onClicked: (menuItem) async {
          bool alwaysOnTop = !(await windowManager.isAlwaysOnTop());
          windowManager.setAlwaysOnTop(alwaysOnTop);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool( "alwaysOnTop", alwaysOnTop );

          await menuItem.setCheck(alwaysOnTop);
        },
      ),
      MenuItemLabel(label: (locale.languageCode == 'en' ? 'Show' : '表示'), onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: (locale.languageCode == 'en' ? 'Quit' : '終了'), onClicked: (menuItem) => appWindow.close()),
    ]);
    await systemTray.setContextMenu(menu);

    // トレイアイコンのクリックイベントハンドラを設定
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });

    // バックグラウンド画像
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyModel.app.imageFlag = prefs.getBool( 'imageFlag' ) ?? false;
    MyModel.app.imageData = prefs.getString( 'imageData') ?? '';
    MyModel.app.imageX = prefs.getDouble( 'imageX_${MyModel.app.imageData.hashCode}') ?? 0.0;
    MyModel.app.imageY = prefs.getDouble( 'imageY_${MyModel.app.imageData.hashCode}') ?? 0.0;
    if( MyModel.app.imageData.isNotEmpty ) {
      MyModel.app.image = MemoryImage( base64.decode( MyModel.app.imageData ) );
    }

    await MyModel.calc.load();

//    await Future.delayed( const Duration( seconds: 3 ), (){ return true; } );

    go( '/number' );
  }

  @override
  void onInit(){
    debugPrint( 'loading onInit' );
  }
  @override
  void onDispose(){
    debugPrint( 'loading onDispose' );
  }
  @override
  void onReady(){
    debugPrint( 'loading onReady' );
  }
  @override
  void onLeave(){
    debugPrint( 'loading onLeave' );
  }
  @override
  void onPause(){
    debugPrint( 'loading onPause' );
  }
  @override
  void onResume(){
    debugPrint( 'loading onResume' );
  }
  @override
  void onBack(){
    debugPrint( 'loading onBack' );
  }
}
