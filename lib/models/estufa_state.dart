class EstufaState {
  double temperatura;
  double umidadeSolo;
  bool modoNoturno;

  bool get ventiladorLigado => temperatura > 30;
  bool get irrigacaoLigada => umidadeSolo < 40;
  bool get luzLigada => modoNoturno;

  EstufaState({
    this.temperatura = 25,
    this.umidadeSolo = 50,
    this.modoNoturno = false,
  });
}