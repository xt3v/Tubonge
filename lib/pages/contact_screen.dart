import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/auth.dart';
import 'dart:convert';
import 'package:tubonge/pages/chat.dart';

class ContactScreen extends StatefulWidget{
  ContactState createState() => ContactState();
}

class ContactState extends State<ContactScreen>{

 List contacts;

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref){
        if(pref.getString("contacts") != null){
         setState(() {
           contacts = json.decode(pref.getString("contacts"));
         });
        }else{
          Firestore.instance.collection("contacts").document(Auth.user.uuid).collection(Auth.user.uuid).getDocuments().then((snapshot){
            List tmpList = new List();
            snapshot.documents.forEach((doc){
              var entry = {
                "name" : doc["name"],
                "avatar" : doc["avatar"],
                "id" : doc["id"],
                "email" : doc["email"],
                "chatId" : doc["chatId"]
              };
              tmpList.add(entry);
            });
            setState(() {
              contacts = tmpList;
            });
            SharedPreferences.getInstance().then((pref){
                pref.setString("contacts",json.encode(contacts));
            });
          });
        }

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contacts == null ? Center(child: CircularProgressIndicator(),):Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
        itemBuilder: (BuildContext con,int index) => buildContact(context,index),
         itemCount: contacts.length,
       )
    ));
  }

  Widget buildContact(BuildContext context,int index) {
    // TODO: implement build
    return  Container(

      padding: EdgeInsets.only(top: 3,bottom: 3,left: 10),
      child: GestureDetector(
        onTap: (){
            openChatScreen(contacts[index]);
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(contacts[index]["avatar"]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(contacts[index]["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ],

                  )
                ],
              ),
              Divider()
            ],
          ),
        )
      ),
    );
  }

  void openChatScreen(contact) {
    Navigator.push(context,
        MaterialPageRoute(builder:(context) => ChatPage(contact,true))
    );
  }


}




