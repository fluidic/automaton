import 'package:automaton/automaton.dart';
import 'package:test/test.dart';

main() {
  Automaton a;

  setUp(() {
    a = new Automaton();

    State s1 = new State();
    a.initial.addTransition(new Transition('init->s1', s1));

    State s2 = new State();
    s1.addTransition(new Transition('s1->s2', s2));

    State s3 = new State();
    s3.accept = true;
    s2.addTransition(new Transition('s2->s3', s3));

    State s4 = new State();
    s4.accept = true;
    s2.addTransition(new Transition('s2->s4', s4));

    State s5 = new State();
    s4.addTransition(new Transition('s4->s5', s5));
  });

  test('getStates', () {
    Set<State> s = a.getStates();

    expect(s.length, equals(6));
  });

  test('getAcceptStates', () {
    Set<State> s = a.getAcceptStates();

    expect(s.length, equals(2));
  });

  test('getLiveStates', () {
    Set<State> s = a.getLiveStates();

    expect(s.length, equals(5));
  });

  test('clone', () {
    Automaton b = a.clone();

    expect(BasicOperations.run(b, ['init->s1', 's1->s2', 's2->s3']), isTrue);
    expect(BasicOperations.run(b, ['init->s1', 's1->s2', 's2->s4']), isTrue);
  });

  test('removeDeadTransitions', () {
    a.removeDeadTransitions();

    Set<State> all = a.getStates();
    expect(all.length, equals(5));

    Set<State> live = a.getLiveStates();
    expect(live.length, equals(5));
  });

  test('getInputStrings', () {
    List<String> inputs = a.getInputStrings();

    expect(inputs.length == 5, isTrue);

    List<String> expected = ['init->s1', 's1->s2', 's2->s3', 's2->s4', 's4->s5'];
    for (String input in inputs) {
      expect(expected.contains(input), isTrue);
    }
  });

  test('totalize', () {
    a.totalize();

    for (State s in a.getStates()) {
      expect(s.transitions.length == 5, isTrue);
    }
  });
}
