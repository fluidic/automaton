import 'package:automaton/automaton.dart';
import 'package:test/test.dart';

main() {
  test('makeEmpty', () {
    Automaton a = BasicAutomata.makeEmpty();
    expect(BasicOperations.run(a, ['a']), isFalse);
  });

  test('default', () {
    Automaton a = BasicAutomata.makeDefault('input');
    expect(BasicOperations.run(a, ['a']), isFalse);
    expect(BasicOperations.run(a, ['input', 'a']), isFalse);
    expect(BasicOperations.run(a, ['a', 'input']), isFalse);
    expect(BasicOperations.run(a, ['input', 'input']), isFalse);
    expect(BasicOperations.run(a, ['input']), isTrue);
  });
}
