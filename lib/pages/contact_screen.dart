import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget{
  ContactState createState() => ContactState();
}

class ContactState extends State<ContactScreen>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
        itemBuilder: (BuildContext con,int index){
            return ContactCard(index);
        },
         itemCount: contacts.length,
       )
    ));
  }

}



List<String> contacts = <String>[
   "Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom","Tom",
];

class ContactCard extends StatelessWidget{
  int index;

  ContactCard(this.index);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(

      padding: EdgeInsets.only(top: 3,bottom: 3,left: 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(radius: 25,),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(contacts[index],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ],
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}