import 'dart:collection';

import 'state.dart';
import 'transition.dart';

enum Minimization { HUFFMAN, BRZOZOWSKI, HOPCROFT }

/// Finite-state automaton
class Automaton {
  static Minimization minimization = Minimization.HOPCROFT;

  State _initial;
  bool _deterministic;

  Automaton() {
    _initial = new State();
    _deterministic = true;
  }

  State get initial => _initial;
  void set initial(State s) {
    _initial = s;
  }

  bool get isDeterministic => _deterministic;
  void set deterministic(bool deterministic) {
    _deterministic = deterministic;
  }

  /// Returns the set of states that are reachable from the initial state.
  Set<State> getStates() {
    Set<State> visited = new HashSet<State>();
    ListQueue<State> worklist = new ListQueue<State>();
    worklist.add(_initial);
    visited.add(_initial);
    while (worklist.length > 0) {
      State s = worklist.removeFirst();
      Iterable<Transition> tr = s.transitions;
      for (Transition t in tr) {
        if (!visited.contains(t.to)) {
          visited.add(t.to);
          worklist.add(t.to);
        }
      }
    }
    return visited;
  }

  /// Returns the set of reachable accept states.
  Set<State> getAcceptStates() {
    HashSet<State> accepts = new HashSet<State>();
    HashSet<State> visited = new HashSet<State>();
    ListQueue<State> worklist = new ListQueue<State>();
    worklist.add(_initial);
    visited.add(_initial);
    while (worklist.length > 0) {
      State s = worklist.removeFirst();
      if (s.isAccept) accepts.add(s);
      for (Transition t in s.transitions) {
        if (!visited.contains(t.to)) {
          visited.add(t.to);
          worklist.add(t.to);
        }
      }
    }
    return accepts;
  }

  /// Returns the set of live states. A state is "live" if an accept state is reachable from it.
  Set<State> getLiveStates({Set<State> states: null}) {
    if (states == null) {
      states = getStates();
    }
    HashMap<State, Set<State>> map = new HashMap<State, Set<State>>();
    for (State s in states) {
      map[s] = new HashSet<State>();
    }
    for (State s in states) {
      for (Transition t in s.transitions) {
        map[t.to].add(s);
      }
    }

    Set<State> live = new HashSet<State>.from(getAcceptStates());
    ListQueue<State> worklist = new ListQueue<State>.from(live);
    while (worklist.length > 0) {
      State s = worklist.removeFirst();
      for (State p in map[s]) {
        if (!live.contains(p)) {
          live.add(p);
          worklist.add(p);
        }
      }
    }
    return live;
  }

  @override
  String toString() {
    StringBuffer b = new StringBuffer();
    Set<State> states = getStates();
    b.write('initial state: ${_initial.id}');
    for (State s in states) {
      b..write('\n')..write(s.toString());
    }
    return b.toString();
  }

  Automaton clone() {
    Automaton a = new Automaton();
    HashMap<State, State> m = new HashMap<State, State>();
    Set<State> states = getStates();
    for (State s in states) {
      m[s] = new State();
    }
    for (State s in states) {
      State p = m[s];
      p.accept = s.isAccept;
      if (s == initial) {
        a.initial = p;
      }
      for (Transition t in s.transitions) {
        p.addTransition(new Transition(t.input, m[t.to]));
      }
    }
    return a;
  }

  void removeDeadTransitions() {
    Set<State> states = getStates();
    Set<State> live = getLiveStates(states: states);
    for (State s in states) {
      Set<Transition> st = s.transitions;
      s.resetTransitions();
      for (Transition t in st) {
        if (live.contains(t.to)) s.addTransition(t);
      }
    }
  }

  List<String> getInputStrings() {
    Set<String> inputset = new HashSet<String>();
    for (State s in getStates()) {
      for (Transition t in s.transitions) {
        inputset.add(t.input);
      }
    }
    List<String> inputs = new List<String>.from(inputset);
    inputs.sort((s1, s2) => s1.compareTo(s2));
    return inputs;
  }

  void totalize() {
    List<String> inputs = getInputStrings();

    State s = new State();
    for (String input in inputs) {
      s.addTransition(new Transition(input, s));
    }

    for (State p in getStates()) {
      Set<String> currentInputset = new HashSet<String>();
      for (Transition t in p.transitions) {
        currentInputset.add(t.input);
      }
      Set<String> inputset = new HashSet<String>.from(inputs);
      inputset.removeAll(currentInputset);
      for (String input in inputset) {
        p.addTransition(new Transition(input, s));
      }
    }
  }
}
