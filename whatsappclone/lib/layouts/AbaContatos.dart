import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/constantes/Firebase.dart';
import 'package:whatsappclone/models/Conversa.dart';
import 'package:whatsappclone/models/Usuario.dart';
import 'package:whatsappclone/router/RouteGenerator.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  /** inicia dados do usuario logado **/
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  /** metodo que recupera os contatos **/
  Future<List<Usuario>> _recuperaContatos() async {
    /** recupera a instancia do firebase database **/
    Firestore banco = Firestore.instance;

    /** recupera da colecao **/
    QuerySnapshot snapshot =
        await banco.collection(Firebase.COLECAO_USUARIOS).getDocuments();

    /** monta a lista para exibicao **/
    List<Usuario> listaUsuario = List();
    for (DocumentSnapshot item in snapshot.documents) {
      var dados = item.data;
      /** para nao aparecer usuario logado na lista **/
      if(dados[Firebase.EMIAL] == _emailUsuarioLogado ) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.emial = dados[Firebase.EMIAL];
      usuario.nome = dados[Firebase.NOME];
      usuario.urlImagem = dados[Firebase.URL_IMAGEM];

      /** adciona na lista **/
      listaUsuario.add(usuario);
    }
    return listaUsuario;
  }

  /** recupera dados do usuario para edicao do perfil **/
  _recuperaDadosUsuario() async {
    /** instacia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    /** recupera dados do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperaContatos(),
      // ignore: missing_return
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  /** recupera lista do metodo **/
                  List<Usuario> listaItens = snapshot.data;
                  Usuario usuario = listaItens[index];

                  return ListTile(
                    /** funcao para abri conversa com passagem de paramentros**/
                    onTap: () {
                      Navigator.pushNamed(context, RouterGenerator.ROTA_MENSAGENS,
                      arguments: usuario);
                    },
                    /** personaliza foto **/
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: usuario.urlImagem != null
                            ? NetworkImage(usuario.urlImagem)
                            : null),
                    /** personaliza nome **/
                    title: Text(
                      usuario.nome,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
