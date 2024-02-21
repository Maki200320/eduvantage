import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tech_media/Firebase_notif_API/Notif_service.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view/splash/splash_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  tz.initializeTimeZones();
  await Firebase.initializeApp();


  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routes = Routes();
    return MaterialApp(
      title: 'EduVantage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterialColor,
        scaffoldBackgroundColor: Color(0xff1d1b00),
        appBarTheme: const AppBarTheme(
          color: AppColors.whiteColor,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 22, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor)
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 40, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
            headline2: TextStyle(fontSize: 32, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
          headline3: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.9),
        headline4: TextStyle(fontSize: 24, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
    headline5: TextStyle(fontSize: 20, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w500, height: 1.6),
    headline6: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            bodyText1: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            bodyText2: TextStyle(fontSize: 14, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, height: 1.6),

            subtitle1: TextStyle(fontSize: 17, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),
            subtitle2: TextStyle(fontSize: 25, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, fontWeight: FontWeight.w700, height: 1.6),

           caption: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular, color: AppColors.bgColor, height: 2.26)

        ),
      ),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: routes.generateRoute,
    );
  }
}

