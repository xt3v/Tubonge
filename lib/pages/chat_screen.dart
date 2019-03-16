import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tubonge/auth.dart';
import 'package:tubonge/pages/chat.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget{
  ChatState createState() => ChatState();
}

class ChatState extends State<ChatScreen>{

  TextEditingController _searchController = new TextEditingController();
  List list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SharedPreferences.getInstance().then((pref){

         if(pref.getString("chats") != null){
           setState(() {
             list = json.decode(pref.getString("chats"));
           });
         }else{
            Firestore.instance.collection("chats").document(Auth.user.uuid).collection(Auth.user.uuid).getDocuments().then((snapshot){
              List tmpList = new List();
              snapshot.documents.forEach((doc){
                 var chat = {
                   "chatId" : doc["chatId"],
                   "name" : doc["name"],
                   "avatar": doc["avatar"],
                   "id"  : doc["id"],
                   "last" : doc["last"]
                 };
                 tmpList.add(chat);
               });
              setState(() {
                list = tmpList;
              });
              SharedPreferences.getInstance().then((pref){
                    pref.setString("chats", json.encode(list));
                });
            });
         }


    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
         body: list == null ? Center(child: CircularProgressIndicator(),):
               Container(
                  padding: EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    itemBuilder: (context,index)=>ChatCard(index),
                    itemCount: list.length,
                  ),
               )
             );

  }

  Widget ChatCard(int index){

      return  GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder:(context) => ChatPage(list[index],false))
            );
          },
          child: Container(
            color:Colors.white,
            padding: EdgeInsets.only(top: 3,bottom: 3,left: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(list[index]["avatar"]),),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(list[index]["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(list[index]["last"]),
                        )
                      ],
                    )
                  ],
                ),
                Divider()
              ],
            ),

          )
      );
    }
  }
