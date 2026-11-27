import 'package:flutter/material.dart';

class Nt {
  final String t, b, time, cat;
  final IconData ic;
  final String? tag, act;
  bool unread;
  Nt(this.t, this.b, this.time, this.cat, this.ic, {this.tag, this.act, this.unread = false});
}
