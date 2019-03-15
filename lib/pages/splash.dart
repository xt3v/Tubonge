import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:tubonge/auth.dart';
import 'package:tubonge/home_page.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget{

  @override
  SplashState createState() => SplashState();

}


class SplashState extends State<SplashScreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //check if there are user details
    SharedPreferences.getInstance().then((pref){
        if(pref.getString("user") != null){
           var user = pref.getString("user");
           var pass = pref.getString("password");
            
           print("User name = $user .. password = $pass");
           
           Auth().signIn(user, pass).then( (user){
               if(user != null){
                 Timer(Duration(milliseconds: 200),()=> Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(
                     builder: (context) => HomePage(user: user),
                   ),
                     (Route<dynamic> r) => false
                 ));
               }
           }).catchError((error){
             Fluttertoast.showToast(
               msg: error.toString(),
               toastLength: Toast.LENGTH_SHORT,
               gravity: ToastGravity.BOTTOM,
               timeInSecForIos: 1,
               backgroundColor: Colors.white,
               textColor: Colors.black,
             );
           });
           
        }else{
           Timer(
             Duration(seconds: 2), 
             () => Navigator.of(context).pushNamedAndRemoveUntil("/Login", (Route<dynamic> route)=>false)
            );
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor:  Theme.of(context).primaryColor,
      body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Icon(Icons.chat_bubble,size: 60,color: Colors.greenAccent,),
             Text("Tubonge",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20,fontWeight: FontWeight.bold,color: Theme.of(context).secondaryHeaderColor)),
             Padding(
               padding: EdgeInsets.only(top: 100),
             ),
             CircularProgressIndicator()
           ],
         ),
      ),
    );
  }
}