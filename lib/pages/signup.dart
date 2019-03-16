import 'package:flutter/material.dart';
import 'package:validate/validate.dart';
import 'package:tubonge/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget{

  @override
  _SignState createState() => _SignState();
}

class _SignData{ 
  String email;
  String userName;
  String password;
  String passwordFirst;
}

class _SignState extends State<SignUpPage>{

  GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  
  _SignData _signdata = new _SignData();
  
  String _validateEmail(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }
    _signdata.passwordFirst = value;
    return null;
  }

  String _validateName(String name){
    if(name.trim().isEmpty){
      return "Username cannot be empty !";
    }
    return null;
  }

  String _validatePasswordRepeat(String passRepeat){
     if(passRepeat != _signdata.passwordFirst){
       return "Passwords do not match !!";
     }
     return null;
  }

  void submit() {
    // First validate form.
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save(); // Save our form now.

     Auth.signUp(_signdata.email, _signdata.password).then((firebaseUser){


        Firestore.instance.collection('users').document(firebaseUser.uid).setData(
            {'name': _signdata.userName, 'id': firebaseUser.uid,'email':firebaseUser.email});

        _formkey.currentState.reset();
        Fluttertoast.showToast(
          msg: "Account created !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
        );

        Navigator.of(context).pushNamedAndRemoveUntil("/Login",(Route<dynamic> route)=>false);

     }).catchError((onError){
       Fluttertoast.showToast(
           msg: onError.toString(),
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.BOTTOM,
           timeInSecForIos: 1,
           backgroundColor: Colors.white,
           textColor: Colors.red,
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
                       key: _formkey,
                       child: Column(
                         children: <Widget>[
                           Padding(
                             padding: EdgeInsets.only(top: 40),
                           ),
                           Icon(Icons.chat_bubble,size: 60,color: Colors.greenAccent,),
                           Text("Tubonge",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 20,fontWeight: FontWeight.bold,color: Colors.greenAccent)),
                           Padding(
                             padding: EdgeInsets.only(top: 60),
                           ),
                           TextFormField(
                               keyboardType: TextInputType.emailAddress,
                               decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   filled: true,
                                   hintText: 'you@example.com',
                                   labelText: 'Email *',
                                   fillColor: Colors.white
                               ),
                               validator: _validateEmail,
                               onSaved: (String email){
                                   _signdata.email = email;
                               },
                           ),
                           Padding(
                             padding: EdgeInsets.only(top: 10),
                           )
                           ,TextFormField(
                               decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   filled: true,
                                   hintText: 'User name',
                                   labelText: 'User Name *',
                                   fillColor: Colors.white
                               ),
                               validator: _validateName,
                               onSaved: (String name){
                                  _signdata.userName = name;
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
                             validator: _validatePassword
                           ),
                           Padding(
                             padding: EdgeInsets.only(top: 10),
                           ),
                           TextFormField(
                             decoration: const InputDecoration(
                                 border: UnderlineInputBorder(),
                                 filled: true,
                                 hintText: 'Repeat Password',
                                 labelText: 'Repeat Password*',
                                 fillColor: Colors.white
                             ),
                             obscureText: true,
                             validator: _validatePasswordRepeat,
                             onSaved: (String password){
                               _signdata.password = password;
                             }
                           )
                           ,
                           Padding(
                             padding: EdgeInsets.only(top: 10),
                           ),
                           MaterialButton(
                             minWidth: 400,
                             color: Colors.greenAccent,
                             child: Text('Sign Up',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                             onPressed:submit,
                             splashColor: Colors.white,
                           )
                           ,Padding(
                             padding: EdgeInsets.only(top: 10),
                           ),
                           GestureDetector(
                             onTap: () {
                               Navigator.of(context).pushNamedAndRemoveUntil("/Login", (Route<dynamic> route) => false);
                             },
                             child: Text('Login',style: TextStyle(decoration:TextDecoration.underline,color: Colors.white),),
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