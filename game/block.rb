class Block
  STONE = {
    item: "⬢",
    char: "██",
    color: nil
  }
  SAND = {
    item: "",
    char: "▒▒",
    color: nil
  }
  DIRT = {
    item: "",
    char: "▓▓",
    color: nil
  }
  GRASS = {
    item: "",
    char: "▔▔",
    color: nil
  }
  AIR = {
    item: "",
    char: "  ",
    color: nil
  }
  ORE = {
    item: "⠶",
    char: "⠰⠆",
    color: nil
  }
  LADDER = {
    item: "ℍ",
    char: "╂╂",
    color: nil
  }
  SOLIDS = [
    STONE,
    SAND,
    DIRT,
    GRASS,
    ORE
  ]
end
