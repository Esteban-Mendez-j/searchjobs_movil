String formatPercent(double v, {int decimals = 1}) =>
    '${v >= 0 ? '+' : ''}${v.toStringAsFixed(decimals)}%';

String formatThousands(num v) => v
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

String formatCompact(double v) => v >= 1000
    ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
    : v.toStringAsFixed(0);

String normalizeText(String s) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  var out = s.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out.trim();
}

/// Calcula techo e intervalo "redondos" para un eje con ~4 divisiones.
({double roof, double interval}) niceAxis(double maxValue, {int divisions = 4}) {
  if (maxValue <= 0) return (roof: divisions.toDouble(), interval: 1);
  final raw = maxValue / divisions;
  var exp = 1.0;
  while (raw / exp >= 10) {
    exp *= 10;
  }
  while (raw / exp < 1) {
    exp /= 10;
  }
  final norm = raw / exp;
  const steps = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 10.0];
  final step = steps.firstWhere((s) => s >= norm, orElse: () => 10.0) * exp;
  return (roof: step * divisions, interval: step);
}
