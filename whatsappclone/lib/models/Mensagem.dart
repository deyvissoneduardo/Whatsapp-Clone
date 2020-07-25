class Mensagem {
  /** atributos **/
  String _idUsuario;
  String _mensagem;
  String _urlImagem;
  String _data;

  /** atributo que define se o tipo da mensagem e texto ou imagem **/
  String _tipo;

  /** construtor **/
  Mensagem();

  /** get e set **/
  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  /* metodo usado para rertona um Map
 * e salvar no firebase
 */
  Map<String, dynamic> toMap() {
    /** criando o map **/
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo": this.tipo,
      "data": this.data
    };
    return map;
  }
}
