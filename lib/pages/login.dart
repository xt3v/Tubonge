import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tubonge/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/home_page.dart';

class LoginPage extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}


class _LoginState extends State<LoginPage>{
   GlobalKey<FormState> _formKey = new GlobalKey();
   _LoginData _loginData = new _LoginData();

   String _validateName(String value){
     if(value.trim().isEmpty){
       return "Username cannot be empty !";
     }
     return null;
   }

   String _validatePassword(String password){
      if(password.trim().isEmpty){
         return "Password cannot be empty !";
      }
      return null;
   }

   void _submit(){
      if(_formKey.currentState.validate()){
          _formKey.currentState.save();

          //Login here
          Auth.signIn(_loginData.username, _loginData.password).then((user){
            print("user = $user");
             if(user != null){
               Fluttertoast.showToast(
                 msg: "Logged in !!",
                 toastLength: Toast.LENGTH_SHORT,
                 gravity: ToastGravity.BOTTOM,
                 timeInSecForIos: 1,
                 backgroundColor: Colors.white,
                 textColor: Colors.black,
               );

               SharedPreferences.getInstance().then((pref){
                 pref.setString("user",user.username);
                 pref.setString("password",user.password);
                 pref.setString("uuid", user.uuid);
                 Auth.user = user;
                 Navigator.pushAndRemoveUntil(
                     context,
                     MaterialPageRoute(
                       builder: (context) => HomePage(user: user),
                     ),
                         (Route<dynamic> route) => false
                 );
               });
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
      }

   }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
         body: Stack(
            fit:StackFit.expand,
            children: <Widget>[
                Container(
                   decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                   child:Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: <Widget>[
                       Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(left: 20,right: 20),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 40),
                                    ),
                                    Icon(Icons.chat_bubble,size: 60,color: Colors.greenAccent,),
                                    Text("Tubonge",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20,fontWeight: FontWeight.bold,color: Colors.greenAccent)),
                                    Padding(
                                      padding: EdgeInsets.only(top: 100),
                                    )
                                    ,TextFormField(
                                        decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            filled: true,
                                            hintText: 'User name',
                                            labelText: 'User Name *',
                                            fillColor: Colors.white
                                        )
                                        ,validator: _validateName,
                                        onSaved: (String value){
                                            _loginData.username = value;
                                        },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          filled: true,
                                          hintText: 'Password',
                                          labelText: 'Password*',
                                          fillColor: Colors.white
                                      ),
                                      obscureText: true,
                                      validator : _validatePassword,
                                      onSaved : (String value){
                                        _loginData.password = value;
                                      }
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                    ),
                                    MaterialButton(
                                      minWidth: 400,
                                      color: Colors.greenAccent,
                                      child: Text('Login',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                      onPressed: _submit,
                                      splashColor: Colors.white,
                                    )
                                    ,Padding(
                                      padding: EdgeInsets.only(top: 10),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamedAndRemoveUntil("/Sign", (Route<dynamic> route) => false);
                                      },
                                      child: Text('Sign up',style: TextStyle(decoration:TextDecoration.underline,color: Colors.white),),
                                    )

                                  ],
                                ),
                            )
                          ),
                       )
                     ],
                   ) ,
                )
            ],
         ),
      );
  }

}


class _LoginData{
   String username;
   String password;
}