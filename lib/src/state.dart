import 'dart:collection';

import 'transition.dart';

/// [Automaton] state
class State implements Comparable<State> {
  bool _accept;
  Set<Transition> _transitions;
  int _id;
  static int _next_id = 0;
  int number;

  State()
      : _accept = false,
        _id = _next_id++ {
    resetTransitions();
  }

  int get id => _id;

  void set accept(bool accept) {
    _accept = accept;
  }

  bool get isAccept => _accept;

  Iterable<Transition> get transitions => _transitions;

  void resetTransitions() {
    _transitions = new HashSet<Transition>();
  }

  void addTransition(Transition t) {
    _transitions.add(t);
  }

  State step(String input) {
    for (Transition t in _transitions) {
      if (t.input == input) return t.to;
    }
    return null;
  }

  @override
  String toString() {
    StringBuffer b = new StringBuffer();
    b.write('state (${_id})');
    if (_accept) {
      b.write(' [accept]');
    } else {
      b.write(' [not accept]');
    }
    b.write(":");
    for (Transition t in _transitions) {
      b..write('\n')..write("  ")..write(t.toString());
    }
    return b.toString();
  }

  @override
  int compareTo(State other) {
    return other.id - _id;
  }

  void addEpsilon(State to) {
    if (to.isAccept) {
      _accept = true;
    }

    for (Transition t in to.transitions) {
      _transitions.add(t);
    }
  }
}
