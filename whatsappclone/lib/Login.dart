import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsappclone/Cadastro.dart';
import 'package:whatsappclone/router//RouteGenerator.dart';

import 'Home.dart';
import 'models/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /** controladores **/
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  /** mensagem de error **/
  String _mensagemError = "";

  /** valida os campos digitados **/
  _validarCamposLogin() {
    /** recupera dados digitados **/
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    /** valida os dados **/
    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        setState(() {
          _mensagemError = "";
        });
        /** usa model de usuario para cadastra **/
        Usuario usuario = Usuario();
        usuario.emial = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemError = "Senha Invalida";
        });
      }
    } else {
      setState(() {
        _mensagemError = "E-mail não cadastrado";
      });
    }
  }

  /** realiza login **/
  _logarUsuario(Usuario usuario) {
    /** recupera a instancia do firebase autenticacao **/
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.emial, password: usuario.senha)
        .then((firebaseUser) {
      /* caso login com sucesso chama tela home
       * com troca de rotas
       */
      Navigator.pushReplacementNamed(context, RouterGenerator.ROTA_HOME);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }).catchError((error) => {
              print('error:' + error),
              setState(() {
                _mensagemError = "Email e/ou senha invalidos";
              })
            });
  }

  /** verifica se usuario esta logado no firebase
   * caso logado nao passa pela tela de login
   */
  Future _verificaUsuarioLogadoFirebase() async {
    /** recupera a instancia do firebase **/
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();
    /** recupera usuario atual caso exista **/
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, RouterGenerator.ROTA_HOME);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _verificaUsuarioLogadoFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                /** input email **/
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    /** personaliza input email **/
                    autofocus: true,
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
                  obscureText: true,
                  controller: _controllerSenha,
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
                      'Entrar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    /** personaliza btn entra **/
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    /** border do btn **/
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _validarCamposLogin();
                    },
                  ),
                ),
                /** opcao de nao tem cadastro **/
                Center(
                  child: GestureDetector(
                    child: Text(
                      'Não tem conta? cadastre-se',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Cadastro()));
                    },
                  ),
                ),
                /** exibe mensagem de error **/
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemError,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
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
