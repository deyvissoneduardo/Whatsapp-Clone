import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/layouts/AbaContatos.dart';
import 'package:whatsappclone/layouts/AbaConversas.dart';
import 'dart:io';
import 'router//RouteGenerator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  /** contreller das abas **/
  TabController _tabController;

  /** cria lista de menu **/
  List<String> itemMenu = ["Configuração", "Deslogar"];

  String _emailUsuario = "";

  Future _recuperarDadosUsuario() async {
    /** recupera a instancia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;
    /** recupera id do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    setState(() {
      _emailUsuario = usuarioLogado.email;
    });
  }

  /** verifica se usuario esta logado **/
  Future _verificaUsuarioLogadoFirebase() async {
    /** recupera a instancia do firebase **/
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();
    /** recupera usuario atual caso exista **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, RouterGenerator.ROTA_lOGIN);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificaUsuarioLogadoFirebase();
    _recuperarDadosUsuario();
    _tabController = TabController(length: 2, vsync: this);
  }

  /** recupera o item de menu selecionado **/
  _escolhaMenuItem(String itemEscolhido) {
    //print(itemEscolhido);
    switch( itemEscolhido ){
      case "Configuração" :
        Navigator.pushNamed(context, RouterGenerator.ROTA_CONFIGURACAO);
       // print("Configuração");
        break;
      case "Deslogar":
        _deslogarUsuario();
      break;
    }
  }

  /** deslogar usuario **/
  _deslogarUsuario() async {
    /** recupera a instancia **/
    FirebaseAuth auth = FirebaseAuth.instance;
    /** desloga usuario**/
    await auth.signOut();

    /** chama tela de login novamente **/
    Navigator.pushReplacementNamed(context, RouterGenerator.ROTA_lOGIN);
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        elevation: Platform.isIOS ? 0 : 4,
        /** criando abas de navegacao **/
        bottom: TabBar(
          /** personaliza abas **/
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Platform.isIOS ? Colors.grey[300] : Colors.white,
          tabs: <Widget>[
            /** abas **/
            Tab(
              text: 'Conversas',
            ),
            Tab(
              text: 'Contatos',
            )
          ],
        ),
        /** monta menu de acoes **/
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              /** constroi a lista de menu **/
              return itemMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          /** exibi de acordo com as tabs **/
          AbaConversas(),
          AbaContatos()
        ],
      ),
    );
  }
}
