import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:whatsappclone/constantes//Firebase.dart';

class Configuracao extends StatefulWidget {
  @override
  _ConfiguracaoState createState() => _ConfiguracaoState();
}

class _ConfiguracaoState extends State<Configuracao> {
  /** controladores **/
  TextEditingController _controllerNome = TextEditingController();

  /** atributo para carreaga imagem selecionada **/
  File _imagem;

  /** inicia id do usuario logado **/
  String _idUsuarioLogado;

  /** atributo que controla progresso de upload **/
  bool _subindoImgem = false;

  /** atributo de recupera url da imagem **/
  String _urlImagemRecuperada;

  /** recupera origem da foto do perfil **/
  Future _recuperaImagem(String origemImagem) async {
    File imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImgem = true;
        _uploadImagem();
      }
    });
  }

  /** carrega a imagem do firebase **/
  Future _uploadImagem() async {
    //* instacia do firebase arquivos**/
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado + ".jpeg");

    /** realiza upload da imagem **/
    StorageUploadTask task = arquivo.putFile(_imagem);

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

  /** metodo que recupera a url do firebase **/
  Future _recuperaUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  /** recupera dados do usuario para edicao do perfil **/
  _recuperaDadosUsuario() async {
    /** instacia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    /** recupera id do usuario logado **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    /** instacia do firebase database **/
    Firestore banco = Firestore.instance;
    /** recupera dados do usuario **/
    DocumentSnapshot snapshot =
        await banco.collection(Firebase.COLECAO_USUARIOS).document(_idUsuarioLogado).get();

    /** Map para pegar dados do usuarios **/
    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados[Firebase.NOME];
    /** verifica se usuario tem foto carregada **/
    if (dados[Firebase.URL_IMAGEM] != null) {
      _urlImagemRecuperada = dados[Firebase.URL_IMAGEM];
    }
  }

  /** autuliza colecao de usuarios adc a url da imagem **/
  _atualizarUrlImagemFirestore(String url) async {
    /** instacia do firebase database **/
    Firestore banco = Firestore.instance;

    /** Map para autualizar dados **/
    Map<String, dynamic> dadosAtualizar = {Firebase.URL_IMAGEM: url};

    /** salva os dados **/
    banco
        .collection(Firebase.COLECAO_USUARIOS)
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);
  }

  /** autuliza nome do usuarios **/
  _atualizarNomeFirestore() async {
    String nome = _controllerNome.text;

    /** instacia do firebase database **/
    Firestore banco = Firestore.instance;

    /** Map para autualizar dados **/
    Map<String, dynamic> dadosAtualizar = {Firebase.NOME: nome};

    /** salva os dados **/
    banco
        .collection(Firebase.COLECAO_USUARIOS)
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Perfil",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                /** exibe carregando imagem **/
                Container(
                  padding: EdgeInsets.all(16),
                  child:
                      _subindoImgem ? CircularProgressIndicator() : Container(),
                ),
                /** imagem de perfil **/
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada)
                        : null),
                /** linha de opçoes de escolha foto **/
                Row(
                  /** centraliza na linha **/
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /** camera **/
                    FlatButton(
                        child: Text('Camera'),
                        onPressed: () {
                          _recuperaImagem("camera");
                        }),
                    /** galeria **/
                    FlatButton(
                        child: Text('Galeria'),
                        onPressed: () {
                          _recuperaImagem("galeria");
                        }),
                  ],
                ),
                /** input nome **/
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    style: TextStyle(fontSize: 20),
                    /** personaliza input **/
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                /** btn salvar **/
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    /** personaliza btn cadastra **/
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    /** border do cadastra **/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
