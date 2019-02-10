import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/auth.dart';


final TextEditingController messageController = new TextEditingController();

class ChatPage extends StatefulWidget{
  var peerData;

  ChatPage(this.peerData);
  
  ChatPageState createState()  => ChatPageState(this.peerData);
}

class ChatPageState extends State<ChatPage>{
  var listMessage;
  var peerData;
  var userId;
  
  ChatPageState(this.peerData);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getCurrentUser().then((user){
       setState(() {
          userId = user.uid;
       });
    });
  }

  final ScrollController listScrollController = new ScrollController();


  Widget build(BuildContext context){
     return Scaffold(
         appBar: AppBar(
           backgroundColor: Theme.of(context).primaryColor,
           bottom:PreferredSize(
            child: Padding(
                padding: EdgeInsets.only(left: 30,bottom: 8),
                child: Row(
                  children: <Widget>[
                     CircleAvatar(backgroundImage: NetworkImage(peerData["avatar"]),),
                     Padding(padding: EdgeInsets.only(left: 30),),
                     Text(peerData["name"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),)
                  ],
                ),
            ),
            preferredSize: null
           ),
         ),
         body: Column(
            children: <Widget>[
              MessageView(),
              InputView()
            ],
         ),
     );
  }

  Widget MessageView(){
    return Flexible(
      child:StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(peerData["id"])
            .collection(peerData["id"])
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildMessageItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget InputView(){
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: test,
                color: Colors.greenAccent,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: test,
                color: Colors.greenAccent,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: messageController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                //focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                color:Colors.greenAccent,
                onPressed: () {onSendMessage(messageController.text, 0);messageController.text = "";},
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildMessageItem(int index,DocumentSnapshot document){
      if(document["idFrom"] == userId){
         if(document["type"] == 0){
           return Wrap(
             direction: Axis.horizontal,
             crossAxisAlignment: WrapCrossAlignment.start,
             spacing: 5,
             runSpacing: 5,
             children: [
                 Container(
                   decoration:BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(40))
                          ),
                   padding: EdgeInsets.all(10),
                   margin: EdgeInsets.only(top: 5,),
                   child:  Text(
                      document['content'],
                      style: TextStyle(color: Colors.black),
                    ),
                 )
               ],
           );
         }else{
           return Wrap(
             direction: Axis.horizontal,
             crossAxisAlignment: WrapCrossAlignment.end,
             spacing: 5,
             runSpacing: 5,
             children: [
               Container(
                 decoration:BoxDecoration(
                     color: Colors.greenAccent,
                     borderRadius: BorderRadius.all(Radius.circular(40))
                 ),
                 padding: EdgeInsets.all(10),
                 margin: EdgeInsets.only(top: 5,),
                 child:  Text(
                   document['content'],
                   style: TextStyle(color: Colors.black),
                 ),
               )
             ],
           );
         }
      }
  }

  test(){

  }

  onSendMessage(String content,int type){
   // messageController.text = "";
    print(" Sh");
    if(content.isNotEmpty){
      var documentReference = Firestore.instance
          .collection('messages')
          .document(peerData["id"])
          .collection(peerData["id"])
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': userId,
            'idTo': 10,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
    }
  }
}


