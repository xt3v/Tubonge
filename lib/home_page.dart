import 'package:flutter/material.dart';
import 'package:tubonge/user.dart';
import 'package:tubonge/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubonge/pages/chat_screen.dart';
import 'package:tubonge/pages/discover_screen.dart';
import 'package:tubonge/pages/contact_screen.dart';

class HomePage extends StatefulWidget{
  HomePage({Key key,@required this.user}): super(key: key);

  final User user;

  @override
  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  _HomeState(this.user):super();
  
  final User user;
  
  TabController _tabController;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 3, vsync: this,initialIndex: 0);
  }
  
  void _signOut(){
    SharedPreferences.getInstance().then((pref){
      pref.remove("user");
      pref.remove("password");
      Auth().signOut();
      Navigator.of(context).pushNamedAndRemoveUntil("/Login", (Route<dynamic> r)=> false);
    });
  }

  void _execute(String choice){
     if(choice.trim() == "Log Out"){
       _signOut();
     }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
       appBar: AppBar(

          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.chat_bubble,color: Theme.of(context).secondaryHeaderColor,),
              Padding(padding: EdgeInsets.only(left: 3),),
              Text("Tubonge",style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),
            ],
          ),
          actions: <Widget>[
             Icon(Icons.search),
             PopupMenuButton(
               itemBuilder: (BuildContext con){
                 return choices.map(
                     (Choice choice){
                        return PopupMenuItem<String>(
                          value: choice.text,
                          child: Row(
                             children: <Widget>[
                               Text(choice.text),
                               Padding(padding: EdgeInsets.only(left: 3),),
                               choice.icon
                             ],
                          ),
                        );
                     }
                 ).toList();
               },
               child: Icon(Icons.more_vert),
               onSelected: _execute,)
          ],

       ),
       body: Center(
          child: TabBarView(
             controller: _tabController,
             children: <Widget>[
               ChatScreen(),
               ContactScreen(),
               DiscoverScreen()
             ],
       ),
       ),
      bottomNavigationBar: Container(
         color: Theme.of(context).primaryColor,
         child:  TabBar(
           indicatorColor: Colors.white,
           controller: _tabController,
           tabs: <Widget>[
             Tab(
               child: Column(
               children: <Widget>[
                 Padding(
                   padding: EdgeInsets.only(top: 5),
                 ),
                 Icon(Icons.chat,color: Theme.of(context).secondaryHeaderColor),
                 Text("chats")
               ],
             )),
             Tab(
                 child: Column(
                   children: <Widget>[
                     Padding(
                       padding: EdgeInsets.only(top: 5),
                     ),
                     Icon(Icons.contacts,color: Theme.of(context).secondaryHeaderColor),
                     Text("contacts")
                   ],
                 )),
             Tab(
                 child: Column(
                   children: <Widget>[
                     Padding(
                       padding: EdgeInsets.only(top: 5),
                     ),
                     Icon(Icons.perm_identity,color: Theme.of(context).secondaryHeaderColor,),
                     Text("discover")
                   ],
                 )),
           ],
         )
          ,
      )
    );
  }

}


List<Choice> choices =  <Choice>[
  Choice("Settings",Icon(Icons.settings)),
  Choice("Log Out",Icon(Icons.exit_to_app))
];

class Choice{
  String text;
  Icon icon;

  Choice(this.text,this.icon);
}
