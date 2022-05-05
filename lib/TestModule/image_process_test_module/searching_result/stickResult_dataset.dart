class StickResultDataset {
  int keton = -1;
  int glucose = -1;
  int leukocyte = -1;
  int nitrite = -1;
  int blood = -1;
  int ph = -1;
  int proteinuria = -1;

  test_print() {
    print("StickResultDataset::test_print");
    print("keton: " + keton.toString());
    print("glucose: " + glucose.toString());
    print("leukocyte: " + leukocyte.toString());
    print("nitrite: " + nitrite.toString());
    print("blood: " + blood.toString());
    print("ph: " + ph.toString());
    print("proteinuria: " + proteinuria.toString());
  }
}
