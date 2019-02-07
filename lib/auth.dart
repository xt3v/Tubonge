import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubonge/user.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<User> signIn(String username, String password) async {
       String email;
       var results = await Firestore.instance.collection("users").where("name",isEqualTo: username.trim()).getDocuments();
       if(results.documents.length == 0){
         return null;
       }else{
         var doc = results.documents.first;
         email = doc.data["email"];
         var _user = _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((firebaseuser){
            User user = new User();
            user.firebaseUser = firebaseuser;
            user.username = username;
            user.password = password;
            return user;
         });
         return _user;
       }

  }

  Future<FirebaseUser> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}