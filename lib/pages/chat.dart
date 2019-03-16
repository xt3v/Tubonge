import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/auth.dart';


final TextEditingController messageController = new TextEditingController();

class ChatPage extends StatefulWidget{
  var peerData;
  var newChat;

  ChatPage(this.peerData,this.newChat);
  
  ChatPageState createState()  => ChatPageState(this.peerData,this.newChat);
}

class ChatPageState extends State<ChatPage>{
  bool newChat;
  bool empty = true;
  var listMessage;
  var peerData;
  var userId;
  bool  isStickerShow;
  bool isLoading;

  ChatPageState(this.peerData,this.newChat);
  FocusNode focusNode = new FocusNode();
  final ScrollController listScrollController = new ScrollController();
  File imageFile;
  String imageUrl;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Chat "+peerData["chatId"]);
    isStickerShow = false;
    focusNode.addListener(onFocusChanged);
    isLoading = false;
    Auth.getCurrentUser().then((user){
       setState(() {
          userId = user.uuid;
       });
    });
  }

  void onFocusChanged(){
     if(focusNode.hasFocus){
       setState(() {
          isStickerShow = false;
       });
     }
  }

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
         body: WillPopScope(
             child:  Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      MessageView(),
                      isStickerShow ? buildStickerView() : Container(),
                      InputView()
                    ],
                  ),
                  buildLoading()
                ],
             ), onWillPop: onBackPress
         )
     );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
          child: Center(
             child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          ),
          color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  Future<bool> onBackPress(){
     if(isStickerShow){
       setState(() {
         isStickerShow = false;
       });
     }else{
       Navigator.pop(context);
     }
     return Future.value(false);
  }


  Widget MessageView(){
    return Flexible(
      child:StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(peerData["chatId"])
            .collection(peerData["chatId"])
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
                )
             );
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
                onPressed: getImage,
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
                onPressed: showSticker,
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
                focusNode: focusNode,
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

  showSticker(){
    focusNode.unfocus();
    setState(() {
      isStickerShow = true;
    });
  }


  Widget buildMessageItem(int index,DocumentSnapshot document){
      if(document["idFrom"] == userId){
         if(document["type"] == 0){
            return Row(
             mainAxisAlignment: MainAxisAlignment.end,
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
         }else if(document["type"] == 2){
           return Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children:[
               new Image.asset(
                 'images/${document['content']}.gif',
                 width: 100.0,
                 height: 100.0,
                 fit: BoxFit.scaleDown,
               ),
             ]
           );
         }else{
           return Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: <Widget>[
               Container(
                 padding: EdgeInsets.all(10),
                 margin: EdgeInsets.only(top: 5,),
                 child:  Material(
                      child: CachedNetworkImage(
                          placeholder: Container(
                            child: CircularProgressIndicator(
                               valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(70.0),
                          ),
                          errorWidget: Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                 ),

               )
             ],
           );
         }
      }else{
         if(document["type"] == 0){
           return Row(
             mainAxisAlignment: MainAxisAlignment.start,
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
         }else if(document["type"] == 2){
           return Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children:[
                 new Image.asset(
                   'images/${document['content']}.gif',
                   width: 100.0,
                   height: 100.0,
                   fit: BoxFit.scaleDown,
                 ),
               ]
           );
         }else{
           return Row(
             mainAxisAlignment: MainAxisAlignment.start,
             children: <Widget>[
               Container(
                 padding: EdgeInsets.all(10),
                 margin: EdgeInsets.only(top: 5,),
                 child:  Material(
                   child: CachedNetworkImage(
                     placeholder: Container(
                       child: CircularProgressIndicator(
                         valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                       ),
                       width: 200.0,
                       height: 200.0,
                       padding: EdgeInsets.all(70.0),
                     ),
                     errorWidget: Material(
                       child: Image.asset(
                         'images/img_not_available.jpeg',
                         width: 200.0,
                         height: 200.0,
                         fit: BoxFit.cover,
                       ),
                       borderRadius: BorderRadius.all(
                         Radius.circular(8.0),
                       ),
                       clipBehavior: Clip.hardEdge,
                     ),
                     imageUrl: document['content'],
                     width: 200.0,
                     height: 200.0,
                     fit: BoxFit.cover,
                   ),
                   borderRadius: BorderRadius.all(Radius.circular(8.0)),
                   clipBehavior: Clip.hardEdge,
                 ),

               )
             ],
           );
         }
      }
  }


  onSendMessage(String content,int type){

    if(content.isNotEmpty){

      var documentReference = Firestore.instance
          .collection('messages')
          .document(peerData["chatId"])
          .collection(peerData["chatId"])
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
    //if a new contact chat has a message sent register as a chat
    if(newChat && empty){
       SharedPreferences.getInstance().then((pref){
         List chats = new List();
          if(pref.getString("chats") != null){
            chats = json.decode(pref.getString("chats"));
          }
         var chat = {
            "chatId" : peerData["chatId"],
            "name" : peerData["name"],
            "avatar": peerData["avatar"],
             "id"  : peerData["id"],
            "last" :" "
         };
          Firestore.instance.collection("chats").document(Auth.user.uuid).collection(Auth.user.uuid).add(chat);

       setState(() {
         chats.add(chat);
       });
          pref.setString("chats",json.encode( chats));
       });
    }

  }

  Widget buildStickerView() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

 Future uploadFile() async{
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      Fluttertoast.showToast(msg: 'Error uploading image !');
    });
  }
}


