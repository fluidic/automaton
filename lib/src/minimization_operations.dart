import 'dart:collection';

import 'automaton.dart';
import 'basic_operations.dart';
import 'state.dart';
import 'transition.dart';

/// Operations for minimizing automaton
class MinimizationOperations {
  static void minimize(Automaton a) {
    switch (Automaton.minimization) {
      case Minimization.HUFFMAN:
        _minimizeHuffman(a);
        break;
      case Minimization.BRZOZOWSKI:
        _minimizeBrzozowski(a);
        break;
      case Minimization.HOPCROFT:
      default:
        _minimizeHopcroft(a);
    }
  }

  static void _minimizeHuffman(Automaton a) {
    throw new Exception('Not implemented');
  }

  static void _minimizeBrzozowski(Automaton a) {
    throw new Exception('Not implemented');
  }

  static void _minimizeHopcroft(Automaton a) {
    BasicOperations.determinize(a);

    Set<Transition> tr = a.initial.transitions;
    if (tr.length == 1) {
      Transition t = tr.first;
      if (t.to == a.initial && t.input == null) return;
    }

    a.totalize();

    // make arrays for numbered states and effective alphabet
    Set<State> ss = a.getStates();
    List<State> states = new List<State>(ss.length);
    int number = 0;
    for (State q in ss) {
      states[number] = q;
      q.number = number++;
    }
    List<String> sigma = a.getInputStrings();

    // initialize data structures
    List<List<ListQueue<State>>> reverse =
        new List<List<ListQueue<State>>>(states.length)
            .map((_) => new List<ListQueue<State>>(sigma.length))
            .toList(growable: false);
    List<List<bool>> reverse_nonempty = new List<List<bool>>(states.length)
        .map((_) => new List<bool>.filled(sigma.length, false))
        .toList(growable: false);
    List<ListQueue<State>> partition = new List<ListQueue<State>>(states.length)
        .map((_) => new ListQueue<State>())
        .toList(growable: false);
    List<int> block = new List<int>.filled(states.length, 0);
    List<List<_StateList>> active = new List<List<_StateList>>(states.length)
        .map((_) => new List<_StateList>(sigma.length))
        .toList(growable: false);
    List<List<_StateListNode>> active2 =
        new List<List<_StateListNode>>(states.length)
            .map((_) => new List<_StateListNode>(sigma.length))
            .toList(growable: false);
    ListQueue<_IntPair> pending = new ListQueue<_IntPair>();
    List<List<bool>> pending2 = new List<List<bool>>(sigma.length)
        .map((_) => new List<bool>.filled(states.length, false))
        .toList(growable: false);
    List<State> split = new List<State>();
    List<bool> split2 = new List<bool>.filled(states.length, false);
    List<int> refine = new List<int>();
    List<bool> refine2 = new List<bool>.filled(states.length, false);
    List<List<State>> splitblock = new List<List<State>>(states.length)
        .map((_) => new List<State>())
        .toList(growable: false);
    for (int q = 0; q < states.length; q++) {
      for (int x = 0; x < sigma.length; x++) {
        reverse[q][x] = new ListQueue<State>();
        active[q][x] = new _StateList();
      }
    }

    // find initial partition and reverse edges
    for (int q = 0; q < states.length; q++) {
      State qq = states[q];
      int j;
      if (qq.isAccept) {
        j = 0;
      } else {
        j = 1;
      }
      partition[j].add(qq);
      block[qq.number] = j;
      for (int x = 0; x < sigma.length; x++) {
        String y = sigma[x];
        State p = qq.step(y);
        reverse[p.number][x].add(qq);
        reverse_nonempty[p.number][x] = true;
      }
    }

    // initialize active sets
    for (int j = 0; j <= 1; j++) {
      for (int x = 0; x < sigma.length; x++) {
        for (State qq in partition[j]) {
          if (reverse_nonempty[qq.number][x]) {
            active2[qq.number][x] = active[j][x].add(qq);
          }
        }
      }
    }

    // initialize pending
    for (int x = 0; x < sigma.length; x++) {
      int a0 = active[0][x].size;
      int a1 = active[1][x].size;
      int j;
      if (a0 <= a1) {
        j = 0;
      } else {
        j = 1;
      }
      pending.add(new _IntPair(j, x));
      pending2[x][j] = true;
    }

    // process pending until fixed point
    int k = 2;
    while (!pending.isEmpty) {
      _IntPair ip = pending.removeFirst();
      int p = ip.n1;
      int x = ip.n2;
      pending2[x][p] = false;
      // find states that need to be split off their blocks
      for (_StateListNode m = active[p][x].first; m != null; m = m.next) {
        for (State s in reverse[m.q.number][x]) {
          if (!split2[s.number]) {
            split2[s.number] = true;
            split.add(s);
            int j = block[s.number];
            splitblock[j].add(s);
            if (!refine2[j]) {
              refine2[j] = true;
              refine.add(j);
            }
          }
        }
      }
      // refine blocks
      for (int j in refine) {
        if (splitblock[j].length < partition[j].length) {
          ListQueue<State> b1 = partition[j];
          ListQueue<State> b2 = partition[k];
          for (State s in splitblock[j]) {
            b1.remove(s);
            b2.add(s);
            block[s.number] = k;
            for (int c = 0; c < sigma.length; c++) {
              _StateListNode sn = active2[s.number][c];
              if (sn != null && sn.sl == active[j][c]) {
                sn.remove();
                active2[s.number][c] = active[k][c].add(s);
              }
            }
          }
          // update pending
          for (int c = 0; c < sigma.length; c++) {
            int aj = active[j][c].size;
            int ak = active[k][c].size;
            if (!pending2[c][j] && 0 < aj && aj <= ak) {
              pending2[c][j] = true;
              pending.add(new _IntPair(j, c));
            } else {
              pending2[c][k] = true;
              pending.add(new _IntPair(k, c));
            }
          }
          k++;
        }
        for (State s in splitblock[j]) split2[s.number] = false;
        refine2[j] = false;
        splitblock[j].clear();
      }
      split.clear();
      refine.clear();
    }

    // make a new state for each equivalence class, set initial state
    List<State> newstates = new List<State>(k);
    for (int n = 0; n < newstates.length; n++) {
      State s = new State();
      for (State q in partition[n]) {
        if (q == a.initial) a.initial = s;
        s.accept = q.isAccept;
        s.number = q.number; // select representative
        q.number = n;
      }
      if (partition[n].isNotEmpty) newstates[n] = s;
    }
    // build transitions and set acceptance
    for (int n = 0; n < newstates.length; n++) {
      State s = newstates[n];
      if (s == null) continue;
      s.accept = states[s.number].isAccept;
      for (Transition t in states[s.number].transitions)
        s.addTransition(new Transition(t.input, newstates[t.to.number]));
    }

    a.removeDeadTransitions();
  }
}

class _IntPair {
  int n1, n2;
  _IntPair(this.n1, this.n2);
}

class _StateList {
  int size = 0;

  _StateListNode first, last;

  _StateListNode add(State q) {
    return new _StateListNode(q, this);
  }
}

class _StateListNode {
  State q;

  _StateListNode next, prev;

  _StateList sl;

  _StateListNode(State q, _StateList sl) {
    this.q = q;
    this.sl = sl;
    if (sl.size++ == 0)
      sl.first = sl.last = this;
    else {
      sl.last.next = this;
      prev = sl.last;
      sl.last = this;
    }
  }

  void remove() {
    sl.size--;
    if (sl.first == this)
      sl.first = next;
    else
      prev.next = next;
    if (sl.last == this)
      sl.last = prev;
    else
      next.prev = prev;
  }
}
