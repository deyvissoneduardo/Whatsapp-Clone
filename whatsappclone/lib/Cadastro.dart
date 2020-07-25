import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsappclone/constantes//Firebase.dart';
import 'package:whatsappclone/models/Usuario.dart';

import 'router/RouteGenerator.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  /** controladores **/
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  /** mensagem de error **/
  String _mensagemError = "";

  /** valida os campos antes de cadastra **/
  _validarCamposCadastro() {
    /** recupera dados digitados **/
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    /** valida os dados **/
    if (nome.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length > 6) {
          setState(() {
            _mensagemError = "";
          });
          /** usa model de usuario para cadastra **/
          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.emial = email;
          usuario.senha = senha;

          _cadastraUsuarioFirebase(usuario);
        } else {
          setState(() {
            _mensagemError = "Senha deve ter no minimo 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemError = "E-mail obrigatorio";
        });
      }
    } else {
      setState(() {
        _mensagemError = 'Preencha o nome';
      });
    }
  }

  /** cadastra o usuario no firebase com model Usuario
   * caso passe pelo metodo de validaCampos()
   */
  _cadastraUsuarioFirebase(Usuario usuario) {
    /** recupera a instancia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.emial, password: usuario.senha)
        .then((firebaseUser) {
      /** salva os dados no firebase **/
      /** recupera a instancia do firebase database**/
      Firestore banco = Firestore.instance;

      /** cria colecao a ser salva **/
      banco
          .collection(Firebase.COLECAO_USUARIOS)
          .document(firebaseUser.uid)
          .setData(usuario.toMap());

      /* caso cadastrado com sucesso chama tela home
       * com troca de rotas para nao volta a tela de login
       * e apaga todas rotas anteriores
       */
      Navigator.pushNamedAndRemoveUntil(
          context, RouterGenerator.ROTA_HOME, (_) => false);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }).catchError((error) {
      setState(() {
        _mensagemError = "Error ao cadastra!!";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              /** ocupa todo espacamento disponivel **/
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                /** logo **/
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Image.asset(
                    "images/usuario.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                /** input nome **/
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    /** personaliza input nome **/
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                /** input email **/
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    /** personaliza input email **/
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  /** personaliza input senha **/
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
                /** btn entrar **/
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      'Cadastrar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    /** personaliza btn cadastra **/
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    /** border do cadastra **/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _validarCamposCadastro();
                    },
                  ),
                ),
                /** exibe mensagem de error **/
                Center(
                  child: Text(
                    _mensagemError,
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
