import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/Login.dart';
import 'package:whatsappclone/router//RouteGenerator.dart';
import 'dart:io';

final ThemeData temaIOS = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25D363)
);

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff075E50),
    accentColor: Color(0xff25D363)
);

void main() {
  /** teste de conexao com firebase
      WidgetsFlutterBinding.ensureInitialized();

      Firestore.instance
      .collection("usuarios")
      .document("001")
      .setData({"nome" : "Deyvisson"});
   **/

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
    /** defini cores padrao **/
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    /** iniciando rotas **/
    initialRoute: '/',
    onGenerateRoute: RouterGenerator.generateRoute,
  ));
}
