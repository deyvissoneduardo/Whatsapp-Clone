class Usuario {
  /** atributos **/
  String _idUsuario;
  String _nome;
  String _emial;
  String _senha;
  String _urlImagem;

  /** contrutor **/
  Usuario();

  /** get e set **/
  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get emial => _emial;

  set emial(String value) {
    _emial = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

/* metodo usado para rertona um Map
 * e salvar no firebase
 */
  Map<String, dynamic> toMap() {
    /** criando o map **/
    Map<String, dynamic> map = {"nome": this.nome, "email": this.emial};
    return map;
  }
}
