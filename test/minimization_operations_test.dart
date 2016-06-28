import 'package:automaton/automaton.dart';
import 'package:test/test.dart';

main() {
  test('HopCraft', () {
    Automaton a = BasicAutomata.makeDefault('input');
    MinimizationOperations.minimize(a);

    expect(BasicOperations.run(a, ['input']), isTrue);

    expect(BasicOperations.run(a, ['input', 'input']), isFalse);
    expect(BasicOperations.run(a, ['input', 'input', 'input']), isFalse);
    expect(BasicOperations.run(a, ['output']), isFalse);
  });

  test('HUFFMAN', () {
    Automaton.minimization = Minimization.HUFFMAN;

    Automaton a = BasicAutomata.makeDefault('input');
    expect(() => MinimizationOperations.minimize(a),
        throwsA(new isInstanceOf<Exception>()));
  });

  test('BRZOZOWSKI', () {
    Automaton.minimization = Minimization.BRZOZOWSKI;

    Automaton a = BasicAutomata.makeDefault('input');
    expect(() => MinimizationOperations.minimize(a),
        throwsA(new isInstanceOf<Exception>()));
  });
}
