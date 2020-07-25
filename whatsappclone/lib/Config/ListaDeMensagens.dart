import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListaDeMensagens extends StatefulWidget {
  @override
  _ListaDeMensagensState createState() => _ListaDeMensagensState();
}
/**
 * estuda passagem de paramentros para usar essa classe
 */
class _ListaDeMensagensState extends State<ListaDeMensagens> {
  /** lista de mensagens **/
  List<String> _listaMensagens = [
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Ola tudo bem?',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    'Tudo sim e contigo',
    '....'
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: _listaMensagens.length,
            itemBuilder: (context, index) {
              /** lagura do container **/
              double larguraContainer = MediaQuery.of(context).size.width * 0.8;
              /** define cores e alinhamentos **/
              Alignment alignment = Alignment.centerRight;
              Color cor = Color(0xffd2ffa5);
              if (index % 2 == 0) {
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
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      _listaMensagens[index],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }));
  }
}
