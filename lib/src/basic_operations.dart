import 'dart:collection';

import 'package:collection/collection.dart';

import 'automaton.dart';
import 'basic_automata.dart';
import 'minimization_operations.dart';
import 'state.dart';
import 'transition.dart';

/// Basic automata operations. Given automata will be mutated.
class BasicOperations {
  static Automaton concatenate(Automaton a1, Automaton a2) {
    if (isEmpty(a1) || isEmpty(a2)) {
      return BasicAutomata.makeEmpty();
    }

    a1 = a1.clone();
    a2 = a2.clone();

    bool deterministic = a1.isDeterministic && a2.isDeterministic;
    for (State s in a1.getAcceptStates()) {
      s.accept = false;
      s.addEpsilon(a2.initial);
    }
    a1.deterministic = deterministic;
    MinimizationOperations.minimize(a1);
    return a1;
  }

  static Automaton concatenateList(List<Automaton> l) {
    if (l.isEmpty) {
      return BasicAutomata.makeDefault('');
    }

    for (Automaton a in l) {
      if (isEmpty(a)) {
        return BasicAutomata.makeEmpty();
      }
    }

    Automaton b = l[0].clone();
    Set<State> ac = b.getAcceptStates();
    for (Automaton a in l.skip(1)) {
      Automaton aa = a.clone();
      Set<State> ns = aa.getAcceptStates();
      for (State s in ac) {
        s.accept = false;
        s.addEpsilon(aa.initial);
      }
      ac = ns;
    }
    b.deterministic = false;
    MinimizationOperations.minimize(b);
    return b;
  }

  static Automaton repeat0(Automaton a) {
    a = a.clone();
    State s = new State();
    s.accept = true;
    s.addEpsilon(a.initial);
    for (State p in a.getAcceptStates()) {
      p.addEpsilon(s);
    }
    a.initial = s;
    a.deterministic = false;
    MinimizationOperations.minimize(a);
    return a;
  }

  static Automaton repeat1(Automaton a) {
    List<Automaton> as = new List<Automaton>();
    as.add(a);
    as.add(repeat0(a));
    return concatenateList(as);
  }

  static Automaton union(Automaton a1, Automaton a2) {
    a1 = a1.clone();
    a2 = a2.clone();

    State s = new State();
    s.addEpsilon(a1.initial);
    s.addEpsilon(a2.initial);
    a1.initial = s;
    a1.deterministic = false;
    MinimizationOperations.minimize(a1);
    return a1;
  }

  static Automaton unionList(List<Automaton> l) {
    State s = new State();
    for (Automaton b in l) {
      if (isEmpty(b)) continue;
      Automaton bb = b.clone();
      s.addEpsilon(bb.initial);
    }
    Automaton a = new Automaton();
    a.initial = s;
    a.deterministic = false;
    MinimizationOperations.minimize(a);
    return a;
  }

  static bool run(Automaton a, Iterable<String> l) {
    State p = a.initial;
    for (String input in l) {
      State q = p.step(input);
      if (q == null) return false;
      p = q;
    }
    return p.isAccept;
  }

  static void determinize(Automaton a) {
    if (a.isDeterministic) return;

    Set<State> initialset = new HashSet<State>();
    initialset.add(a.initial);

    List<String> inputs = a.getInputStrings();

    // subset construction
    Map<Set<State>, Set<State>> sets = new HashMap<Set<State>, Set<State>>(
        equals: (key1, key2) => const SetEquality().equals(key1, key2),
        hashCode: (key) => const SetEquality().hash(key));
    ListQueue<Set<State>> worklist = new ListQueue<Set<State>>();
    Map<Set<State>, State> newstate = new HashMap<Set<State>, State>(
        equals: (key1, key2) => const SetEquality().equals(key1, key2),
        hashCode: (key) => const SetEquality().hash(key));
    sets[initialset] = initialset;
    worklist.add(initialset);
    a.initial = new State();
    newstate[initialset] = a.initial;

    while (worklist.length > 0) {
      Set<State> s = worklist.removeFirst();
      State r = newstate[s];
      for (State q in s) {
        if (q.isAccept) {
          r.accept = true;
          break;
        }
      }
      for (int n = 0; n < inputs.length; n++) {
        Set<State> p = new HashSet<State>();
        for (State q in s) {
          for (Transition t in q.transitions) {
            if (t.input == inputs[n]) p.add(t.to);
          }
        }
        if (!sets.containsKey(p)) {
          sets[p] = p;
          worklist.add(p);
          newstate[p] = new State();
        }
        State q = newstate[p];
        r.addTransition(new Transition(inputs[n], q));
      }
    }
    a.deterministic = true;
    a.removeDeadTransitions();
  }

  static bool isEmpty(Automaton a) {
    return !a.initial.isAccept && a.initial.transitions.isEmpty;
  }
}
