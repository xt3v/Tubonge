import 'package:flutter/material.dart';
import 'package:tubonge/home_page.dart';
import 'package:tubonge/pages/login.dart';
import 'package:tubonge/pages/signup.dart';
import 'package:tubonge/pages/splash.dart';
import 'package:tubonge/pages/chat.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title:"Tobonge",
       theme: ThemeData(
         primaryColor: Colors.black,
         secondaryHeaderColor: Colors.greenAccent
       ),
       routes: <String,WidgetBuilder>{
         '/Home' : (BuildContext context) => HomePage(),
         '/Sign' : (BuildContext context) => SignUpPage(),
         '/Login' : (BuildContext context) => LoginPage()
      },
       home: SplashScreen(),
    );
  }

}