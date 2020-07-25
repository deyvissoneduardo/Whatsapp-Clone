import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/constantes/Firebase.dart';
import 'package:whatsappclone/models/Conversa.dart';
import 'package:whatsappclone/models/Usuario.dart';
import 'package:whatsappclone/router/RouteGenerator.dart';
import 'dart:async';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  /** cria lista de conversas **/
  List<Conversa> _listaConversas = List();

  /** controller do stream **/
  final _controller = StreamController<QuerySnapshot>.broadcast();

  /** instancia do firestore database **/
  Firestore banco = Firestore.instance;

  /** inicia id do usuario logado **/
  String _idUsuarioLogado;

  /** metodo que verifica modificações nas conversa **/
  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = banco
        .collection(Firebase.COLECAO_CONVERSA)
        .document(_idUsuarioLogado)
        .collection(Firebase.COLECAO_ULT_CONVERSA)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  /** recupera dados do usuario **/
  _recuperaDadosUsuario() async {
    /** instacia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    /** recupera id do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    /** adiciona ouvinte(listenner) na conversa**/
    _adicionarListenerConversas();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
    Conversa conversa = Conversa();
    conversa.nome = "Prof";
    conversa.mensagem = "Como ta o curso";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-8490a.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=95eb0d27-1398-4459-a288-7f2d36b4a636";

    _listaConversas.add(conversa);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando Conversa"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              /** veririfica se a erros na mensagem **/
              return Text("Erro ao carrega mensagens");
            } else {
              /** recupera dados do firebase **/
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Ainda Não existe conversa :(",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
                );
                break;
              }
              return ListView.builder(
                  itemCount: _listaConversas.length,
                  itemBuilder: (context, index) {
                    /** recupera mensagem **/
                    List<DocumentSnapshot> conversa =
                        querySnapshot.documents.toList();
                    // print(mensagem);
                    DocumentSnapshot item = conversa[index];

                    String urlImagem = item['caminhoFoto'];
                    String tipo = item['tipoMensagem'];
                    String mensagem = item['mensagem'];
                    String nome = item['nome'];
                    String idDestinatario = item['idDestinatario'];

                    Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.urlImagem = urlImagem;
                    usuario.idUsuario = idDestinatario;

                    return ListTile(
                      /** funcao para abri conversa **/
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouterGenerator.ROTA_MENSAGENS,
                            arguments: usuario);
                      },
                      /** personaliza foto **/
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            urlImagem != null ? NetworkImage(urlImagem) : null,
                      ),
                      /** personaliza nome **/
                      title: Text(
                        nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      /** personaliza mensagem **/
                      subtitle: Text(
                        tipo == 'texto' ? mensagem : 'Foto',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  });
            }
        }
      },
    );
  }
}
