import 'automaton.dart';
import 'state.dart';
import 'transition.dart';

class BasicAutomata {
  static Automaton makeDefault(String s) {
    Automaton a = new Automaton();
    State initial = a.initial;
    State newState = new State();
    newState.accept = true;
    initial.addTransition(new Transition(s, newState));
    return a;
  }

  static Automaton makeEmpty() {
    Automaton a = new Automaton();
    return a;
  }
}
