class Compound {
  final String name;
  final double max;

  static final compoundIds = Map.of({
    "SO2": FixedCompound.so2,
    "C6H6": FixedCompound.c6h6,
    "NO2": FixedCompound.no2,
    "O3": FixedCompound.o3,
    "PM2.5": FixedCompound.pm25,
    "PM10": FixedCompound.pm10,
    "CO": FixedCompound.co
  });

  const Compound({
    required this.name,
    required this.max,
  });
}

enum FixedCompound {
  so2(compound: Compound(name: "SO₂", max: 350)),
  c6h6(compound: Compound(name: "C₆H₆", max: 5)),
  no2(compound: Compound(name: "NO₂", max: 200)),
  o3(compound: Compound(name: "O₃", max: 180)),
  pm25(compound: Compound(name: "PM 2.5", max: 25)),
  pm10(compound: Compound(name: "PM 10", max: 50)),
  co(compound: Compound(name: "CO", max: 10000));

  final Compound compound;
  const FixedCompound({required this.compound});
}
