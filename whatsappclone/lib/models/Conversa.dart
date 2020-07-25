import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsappclone/constantes/Firebase.dart';

class Conversa {
  /** atributos **/
  String _idRemetente;
  String _idDestinatario;
  String _nome;
  String _mensagem;
  String _caminhoFoto;
  String _tipoMensagem;

  /** tipo = "texto" ou "imagem"**/

  /** contrutor **/
  Conversa();

  /** get e set **/
  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idDestinatario => _idDestinatario;

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  /** metodo para salvar conversas **/
  salvarConversas() async {
    Firestore banco = Firestore.instance;

    await banco.collection(Firebase.COLECAO_CONVERSA)
    .document(this.idRemetente)
    .collection(Firebase.COLECAO_ULT_CONVERSA)
    .document( this.idDestinatario)
    .setData(this.toMap());
  }
/* metodo usado para rertona um Map
 * e salvar no firebase
 */
  Map<String, dynamic> toMap() {
    /** criando o map **/
    Map<String, dynamic> map = {
      "idRemetente"   : this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "idDestinatario": this.idDestinatario,
      "nome"          : this.nome,
      "mensagem"      : this.mensagem,
      "caminhoFoto"   : this.caminhoFoto,
      "tipoMensagem"  : this.tipoMensagem,
    };
    return map;
  }

}
