import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/constantes/Firebase.dart';
import 'package:whatsappclone/models/Mensagem.dart';
import 'package:whatsappclone/models/Usuario.dart';

/**
 * estuda passagem de paramentros para usar essa classe
 */
class CaixaDeMensagem extends StatefulWidget {
  @override
  _CaixaDeMensagemState createState() => _CaixaDeMensagemState();
}

class _CaixaDeMensagemState extends State<CaixaDeMensagem> {
  /** controladores **/
  TextEditingController _controllerMensagem = TextEditingController();

  /** inicia id do usuario logado **/
  String _idUsuarioLogado;

  /** inicia id do usuario destinatario **/
  String _idUsuarioDestinatario;

  /** funcao de enviar mensagem **/
  _enviarMensagem() {
    /** pega texto da mensagem **/
    String textoMensagem = _controllerMensagem.text;

    /** verfica se o texto nao e vazio antes de enviar **/
    if (textoMensagem.isNotEmpty) {
      /** pega modelo de mensagem para salvar **/
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    }
  }

  /** salva mensagem no firebase **/
  _salvarMensagem(
      String idRementente, String idDestinatario, Mensagem mensagem) async {
    /** recupera instacia do fireabse database **/
    Firestore banco = Firestore.instance;

    /** salva mensagem no firebase **/
    await banco
        .collection(Firebase.COLECAO_MENSAGEM)
        .document(idRementente)
        .collection(idDestinatario)
        .add(mensagem.toMap());
  }

  /** funcao de enviar foto **/
  _enviarFoto() {}

  /** recupera dados do usuario **/
  _recuperaDadosUsuario() async {
    /** instacia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    /** recupera id do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          /** caixa de texto **/
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              /** cria a caixa de texto **/
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    suffix: IconButton(
                        icon: Icon(Icons.camera_alt), onPressed: _enviarFoto)),
              ),
            ),
          ),
          /** btn de enviar mensagem **/
          FloatingActionButton(
            backgroundColor: Color(0xff075E50),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    ));
  }
}
