import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsappclone/Config/CaixaMensagem.dart';
import 'package:whatsappclone/Config/ListaDeMensagens.dart';
import 'package:whatsappclone/models/Conversa.dart';
import 'constantes/Firebase.dart';
import 'models/Mensagem.dart';
import 'models/Usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Mensagens extends StatefulWidget {
  /** recebe o valor por paramentro de AbaContatos **/
  Usuario contatos;

  /** construtor **/
  Mensagens(this.contatos);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  /** controladores **/
  TextEditingController _controllerMensagem = TextEditingController();

  /** recupera instacia do fireabse database **/
  Firestore banco = Firestore.instance;

  /** atributo para envio de imagens **/
  File _imagem;

  /** atributo que controla progresso de upload **/
  bool _subindoImgem = false;

  /** inicia id do usuario logado **/
  String _idUsuarioLogado;

  /** inicia id do usuario destinatario **/
  String _idUsuarioDestinatario;

  /** controller do stream **/
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  /** metodo que verifica modificações nas mensagens **/
  Stream<QuerySnapshot> _adicionarListenerMensagens() {
    final stream = banco
        .collection(Firebase.COLECAO_MENSAGEM)
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

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
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";

      /** salva mensagem remetente **/
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      /** salva mensagem destinatario **/
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      /** salvando conversa **/
      _salvarConversa(mensagem);
    }
  }

  /** metodo que salva conversa **/
  _salvarConversa(Mensagem mensagem) {
    /** salva conversa para remetente **/
    Conversa cRementente = Conversa();
    cRementente.idRemetente = _idUsuarioLogado;
    cRementente.idDestinatario = _idUsuarioDestinatario;
    cRementente.mensagem = mensagem.mensagem;
    cRementente.nome = widget.contatos.nome;
    cRementente.caminhoFoto = widget.contatos.urlImagem;
    cRementente.tipoMensagem = mensagem.tipo;
    cRementente.salvarConversas();

    /** salva conversa para destinatario **/
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = mensagem.mensagem;
    cDestinatario.nome = widget.contatos.nome;
    cDestinatario.caminhoFoto = widget.contatos.urlImagem;
    cDestinatario.tipoMensagem = mensagem.tipo;
    cDestinatario.salvarConversas();
  }

  /** salva mensagem no firebase **/
  _salvarMensagem(
      String idRementente, String idDestinatario, Mensagem mensagem) async {
    /** salva mensagem no firebase **/
    await banco
        .collection(Firebase.COLECAO_MENSAGEM)
        .document(idRementente)
        .collection(idDestinatario)
        .add(mensagem.toMap());

    /** limpa texto apos envio **/
    _controllerMensagem.clear();
  }

  /** funcao de enviar foto **/
  _enviarFoto() async {
    File imagemSelecionada;
    imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    _subindoImgem = true;
    /** cria identificador unico **/
    String nomeImgem = DateTime.now().millisecondsSinceEpoch.toString();

    /** carrega a imagem do firebase **/
    //* instacia do firebase arquivos**/
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImgem + ".jpg");

    /** realiza upload da imagem **/
    StorageUploadTask task = arquivo.putFile(imagemSelecionada);

    /** controla o progesso da imagem **/
    task.events.listen((StorageTaskEvent storageTaskEvent) {
      if (storageTaskEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImgem = true;
        });
      } else if (storageTaskEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImgem = false;
        });
      }
    });

    /** recupera a url da imagem **/
    task.onComplete
        .then((StorageTaskSnapshot snapshot) => {_recuperaUrlImagem(snapshot)});
  }

  /** recupera url da imagem **/
  Future _recuperaUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    /** pega modelo de mensagem para imagem **/
    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";

    /** salva mensagem remetente **/
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    /** salva mensagem destinatario **/
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  /** recupera dados do usuario **/
  _recuperaDadosUsuario() async {
    /** instacia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    /** recupera id do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    /** recupera id do usuario destinatario **/
    _idUsuarioDestinatario = widget.contatos.idUsuario;

    /** adicinar listener nas mensagens **/
    _adicionarListenerMensagens();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    /** cria caixa de mensagem **/
    var _caixaMensagem = Container(
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
                    suffix: _subindoImgem
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _enviarFoto)),
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
    );
    /** fim do container caixa de mensagem **/

    /** caixa de lista de mensagens **/
    var strem = StreamBuilder(
        /** monitora e exibe mensagem instaneamente **/
        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
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
              /** recupera dados do firebase **/
              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                /** veririfica se a erros na mensagem **/
                return Text("Erro ao carrega mensagens");
              } else {
                return Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: querySnapshot.documents.length,
                        itemBuilder: (context, index) {
                          /** recupera mensagem **/
                          List<DocumentSnapshot> mensagem =
                              querySnapshot.documents.toList();
                          // print(mensagem);
                          DocumentSnapshot item = mensagem[index];

                          /** lagura do container **/
                          double larguraContainer =
                              MediaQuery.of(context).size.width * 0.8;
                          /** define cores e alinhamentos **/
                          Alignment alignment = Alignment.centerRight;
                          Color cor = Color(0xffd2ffa5);
                          if (_idUsuarioLogado != item['idUsuario']) {
                            /** par **/
                            alignment = Alignment.centerLeft;
                            cor = Colors.white;
                          }
                          return Align(
                            /** centraliza mensagens da conversa **/
                            alignment: alignment,
                            child: Padding(
                              /** espaçamento entre mensagens **/
                              padding: EdgeInsets.all(6),
                              child: Container(
                                width: larguraContainer,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: cor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: /** mostra mensagem **/
                                    item['tipo'] == 'texto'
                                        ? Text(
                                            item['mensagem'],
                                            style: TextStyle(fontSize: 18),
                                          )
                                        : Image.network(item['urlImagem']),
                              ),
                            ),
                          );
                        }));
              }
              break;
          }
        });

    /** fim da caixa de lista **/
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contatos.urlImagem != null
                  ? NetworkImage(widget.contatos.urlImagem)
                  : null,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(widget.contatos.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        /** adiona imagem de fundo **/
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  /** listview mensagem **/
                  strem,
                  // ListaDeMensagens(),
                  /** input mensagem **/
                  _caixaMensagem
                  //CaixaDeMensagem();
                ],
              )),
        ),
      ),
    );
  }
}
