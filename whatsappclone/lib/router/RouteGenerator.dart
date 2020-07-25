import 'package:flutter/material.dart';
import 'package:whatsappclone/Cadastro.dart';
import 'package:whatsappclone/Configuracao.dart';
import 'package:whatsappclone/Home.dart';
import 'package:whatsappclone/Login.dart';
import 'package:whatsappclone/Mensagens.dart';

class RouterGenerator {

  /** constantes para defini nome de rotas **/
  static const String ROTA_INICIAL = "/";
  static const String ROTA_lOGIN = "/login";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_HOME = "/home";
  static const String ROTA_CONFIGURACAO = "/configuracao";
  static const String ROTA_MENSAGENS = "/mensagens";

  /** metodo que gera a rota selecionada **/
  static Route<dynamic> generateRoute(RouteSettings settings) {
    /** configuracao para passagem de argumentos **/
    final args = settings.arguments;

    /** recupera rota pelo nome **/
    switch (settings.name) {
      case ROTA_INICIAL:
        return MaterialPageRoute(builder: (_) => Login());
      case ROTA_lOGIN:
        return MaterialPageRoute(builder: (_) => Login());
      case ROTA_CADASTRO:
        return MaterialPageRoute(builder: (_) => Cadastro());
      case ROTA_HOME:
        return MaterialPageRoute(builder: (_) => Home());
      case ROTA_CONFIGURACAO:
        return MaterialPageRoute(builder: (_) => Configuracao());
      case ROTA_MENSAGENS:
        return MaterialPageRoute(builder: (_) => Mensagens(args));
      default:
        _errorRota();
    }
  }

  /** metodo de configuracao de erros de rotas **/
  static Route<dynamic> _errorRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela Não Encontrada"),
        ),
        body: Center(
          child: Text("Tela Não Encontrada"),
        ),
      );
    });
  }
}
