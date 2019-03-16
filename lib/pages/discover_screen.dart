import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/auth.dart';
class DiscoverScreen extends StatefulWidget{
  DiscoverState createState() => DiscoverState();

}

class DiscoverState extends State<DiscoverScreen>{
  final ScrollController listScrollController = new ScrollController();
  TextEditingController searchController = new TextEditingController();
  var userId;
  List listContacts = new List();

  List<DocumentSnapshot> docs = new List();
  List<DocumentSnapshot> resultDocs = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth.getCurrentUser().then((user){
      setState(() {
        userId = user.uuid;
      });
    });

    SharedPreferences.getInstance().then((pref){
      if(pref.getString("contacts") != null){
          setState(() {
            listContacts = json.decode(pref.getString("contacts"));
          });
      }else{
        Firestore.instance.collection("contacts").document(userId).collection(userId).getDocuments().then((snapshot){
           snapshot.documents.forEach((doc){
             var entry = {
               "name" : doc["name"],
               "avatar" : doc["avatar"],
               "id" : doc["id"],
               "email" : doc["email"],
               "chatId" : doc["chatId"]
             };
             setState(() {
               listContacts.add(entry);
             });
           });

        });
      }
    });
    getUsers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomPadding: false,
         body:Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10,right: 10,top:2),
                  height: 40,
                  child:  TextField(
                    onChanged: (value){
                       searchUsers(value);
                    },
                    style:TextStyle(
                       height: 1
                    ),
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search,),
                        contentPadding: EdgeInsets.all(2),
                        border: OutlineInputBorder( 
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                    ),
                  )
                ),
                 Expanded(
                   child: ListView.builder(
                       itemBuilder: (context,index) => buildCard(index),
                       itemCount: resultDocs.length,
                       controller: listScrollController,
                   ),
                 )
              ],
          )
      );
  }

  Widget buildCard(int index) {
    var doc = resultDocs[index];
    return  GestureDetector(
      onTap: () {_showAddContactDialog(doc);},
      child: Container(
        color:Colors.white,
        padding: EdgeInsets.only(top: 3,bottom: 3,left: 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(doc["avatar"]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(doc["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  ],
                )
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  void searchUsers(String key) {
    if(!key.trim().isEmpty){
      setState(() {
        resultDocs.clear();
        docs.forEach((doc){
          if(doc["name"].toString().indexOf(key) > -1){
            resultDocs.add(doc);
          }
        });
      });
    }
  }

  void getUsers(){
    Firestore.instance.collection("users").getDocuments().then((snapshot) {
      List<DocumentSnapshot> toAdd = new List();
      snapshot.documents.forEach((doc){
        if(doc["id"] != userId){
          var add = true;
          for(var contact in listContacts){
            if(contact["id"] == doc["id"]){
              add = false;
              break;
            }
          }

          if(add){
            setState(() {
              toAdd.add(doc);
            });
          }

        }
      });
      setState(() {
        docs.addAll(toAdd);
      });
    }).catchError((onError){
      debugPrint(onError);
    });
  }

  void _showAddContactDialog(DocumentSnapshot doc){
    showDialog(
        context: context,
        builder: (BuildContext context){
           return AlertDialog(
              title: Text("Add Contact",textAlign: TextAlign.center,),
              content: Padding(
                  padding: EdgeInsets.only(top:4,left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                   mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(doc["avatar"]),
                 ),
                 Padding(padding: EdgeInsets.only(top: 4),),
                 Text(doc["name"],style: TextStyle(fontSize: 30),)
                ],
              )
           ),
           actions: <Widget>[
             FlatButton(
               child: Text('No'),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
             FlatButton(
               child: Text('Yes'),
               onPressed: () {
                 saveContact(doc);
                 Navigator.of(context).pop();
               },
             )
           ],
         );
        }
    );
  }

  void saveContact(DocumentSnapshot doc) {
      setState(() {
        String chatId;
        Firestore
             .instance
             .collection("chatId").where("user_1",isEqualTo: doc["id"])
              .where("user_2",isEqualTo: userId).getDocuments()
              .then((snapshot){
                    if(!(snapshot.documents.length > 0)){
                      Firestore
                          .instance
                          .collection("chatId").where("user_1",isEqualTo: userId)
                          .where("user_2",isEqualTo: doc["id"]).getDocuments()
                          .then((snapshot2){
                                 if(snapshot2.documents.length > 0){
                                    chatId = snapshot2.documents[0]["chat_id"];
                                 }else{
                                    chatId = "no";
                                 }
                                 saveContactPreference(chatId, doc,listContacts);
                          });
                    }else{
                          chatId = snapshot.documents[0]["chat_id"];
                          saveContactPreference(chatId, doc,listContacts);
                    }


              });
       });
  }

   void saveContactPreference(String chatId,DocumentSnapshot doc,List list){
     if(chatId == "no"){
       chatId = userId+DateTime.now().millisecondsSinceEpoch.toString();

       Firestore.instance.collection("chatId").add({ "user_1" : userId,"user_2" : doc["id"],"chat_id":chatId});
     }

    var entry = {
         "name" : doc["name"],
         "avatar" : doc["avatar"],
         "id" : doc["id"],
         "email" : doc["email"],
         "chatId" : chatId
     };
    setState(() {
      list.add(entry);
    });
     SharedPreferences.getInstance().then((pref){
        pref.setString("contacts", json.encode(list));
     });

     setState(() {
       listContacts.add(entry);
       getUsers();
     });
     Firestore.instance.collection("contacts").document(userId).collection(userId).add(entry);
   }

}

