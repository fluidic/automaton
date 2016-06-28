import 'package:automaton/automaton.dart';
import 'package:test/test.dart';

main() {
  test('concatenate', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicAutomata.makeDefault('b');
    Automaton a3 = BasicOperations.concatenate(a1, a2);

    expect(BasicOperations.run(a3, ['a', 'b']), isTrue);

    expect(BasicOperations.run(a3, ['a']), isFalse);
    expect(BasicOperations.run(a3, ['b']), isFalse);
    expect(BasicOperations.run(a3, ['a', 'c']), isFalse);
    expect(BasicOperations.run(a3, ['c', 'b']), isFalse);
    expect(BasicOperations.run(a3, ['a', 'b', 'a']), isFalse);
    expect(BasicOperations.run(a3, ['a', 'b', 'a', 'b']), isFalse);
  });

  test('concatenateList', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicAutomata.makeDefault('b');
    Automaton a3 = BasicAutomata.makeDefault('c');
    Automaton a4 = BasicOperations.concatenateList([a1, a2, a3]);

    expect(BasicOperations.run(a4, ['a', 'b', 'c']), isTrue);

    expect(BasicOperations.run(a4, ['a']), isFalse);
    expect(BasicOperations.run(a4, ['b']), isFalse);
    expect(BasicOperations.run(a4, ['c']), isFalse);
    expect(BasicOperations.run(a4, ['a', 'c']), isFalse);
    expect(BasicOperations.run(a4, ['c', 'b']), isFalse);
    expect(BasicOperations.run(a4, ['a', 'b', 'a']), isFalse);
  });

  test('repeat0', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicOperations.repeat0(a1);

    expect(BasicOperations.run(a2, []), isTrue);
    expect(BasicOperations.run(a2, ['a']), isTrue);
    expect(BasicOperations.run(a2, ['a', 'a']), isTrue);
    expect(BasicOperations.run(a2, ['a', 'a', 'a']), isTrue);

    expect(BasicOperations.run(a2, ['a', 'b', 'b']), isFalse);
  });

  test('repeat1', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicOperations.repeat1(a1);

    expect(BasicOperations.run(a2, ['a']), isTrue);
    expect(BasicOperations.run(a2, ['a', 'a']), isTrue);
    expect(BasicOperations.run(a2, ['a', 'a', 'a']), isTrue);

    expect(BasicOperations.run(a2, []), isFalse);
    expect(BasicOperations.run(a2, ['a', 'b', 'b']), isFalse);
  });

  test('union', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicAutomata.makeDefault('b');
    Automaton a3 = BasicOperations.union(a1, a2);

    expect(BasicOperations.run(a3, ['a']), isTrue);
    expect(BasicOperations.run(a3, ['b']), isTrue);

    expect(BasicOperations.run(a3, ['a', 'b']), isFalse);
    expect(BasicOperations.run(a3, ['b', 'a']), isFalse);
    expect(BasicOperations.run(a3, ['c', 'b']), isFalse);
    expect(BasicOperations.run(a3, ['a', 'b', 'a']), isFalse);
  });

  test('unionList', () {
    Automaton a1 = BasicAutomata.makeDefault('a');
    Automaton a2 = BasicAutomata.makeDefault('b');
    Automaton a3 = BasicAutomata.makeDefault('c');
    Automaton a4 = BasicOperations.unionList([a1, a2, a3]);

    expect(BasicOperations.run(a4, ['a']), isTrue);
    expect(BasicOperations.run(a4, ['b']), isTrue);
    expect(BasicOperations.run(a4, ['c']), isTrue);

    expect(BasicOperations.run(a4, ['a', 'b', 'c']), isFalse);
    expect(BasicOperations.run(a4, ['a', 'c']), isFalse);
    expect(BasicOperations.run(a4, ['c', 'b']), isFalse);
    expect(BasicOperations.run(a4, ['a', 'b', 'a']), isFalse);
  });

  test('determinize', () {
    Automaton a = new Automaton();
    State s1 = new State();
    a.initial.addTransition(new Transition('a', s1));
    State s2 = new State();
    a.initial.addTransition(new Transition('a', s2));
    State s3 = new State();
    s3.accept = true;
    s1.addTransition(new Transition('b', s3));
    s2.addTransition(new Transition('b', s3));

    a.deterministic = false;

    BasicOperations.determinize(a);

    expect(a.getStates().length, equals(3));
    expect(a.getLiveStates().length, equals(3));

    expect(BasicOperations.run(a, ['a', 'b']), isTrue);
    expect(BasicOperations.run(a, ['a']), isFalse);
    expect(BasicOperations.run(a, ['b']), isFalse);
    expect(BasicOperations.run(a, ['b', 'a']), isFalse);
    expect(BasicOperations.run(a, ['a', 'b', 'a']), isFalse);
    expect(BasicOperations.run(a, ['a', 'b', 'a', 'b']), isFalse);
  });

  test('isEmptyReject', () {
    Automaton a = BasicAutomata.makeEmpty();
    expect(BasicOperations.isEmpty(a), isTrue);
  });
}
