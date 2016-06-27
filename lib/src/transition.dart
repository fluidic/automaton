import 'state.dart';

/// [Automaton] transition
class Transition {
  State _to;
  String _input;

  Transition(this._input, this._to);

  State get to => _to;
  String get input => _input;

  @override
  String toString() {
    StringBuffer b = new StringBuffer();
    b..write(_input)..write(' -> ')..write('state (${_to.id})');
    return b.toString();
  }
}
