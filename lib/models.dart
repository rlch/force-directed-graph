import 'dart:math';

import 'package:vector_math/vector_math.dart';

class Vertex {
  late String id;
  Vector2 pos;
  Vector2 disp;

  Vertex(this.pos, this.disp, {this.id = ''}) {
    if (id.isEmpty)
      id = String.fromCharCodes(
          List.generate(5, (index) => Random().nextInt(33) + 89));
  }

  @override
  String toString() => '(${pos.x}, ${pos.y})';

  Vertex.clone(Vertex vertex)
      : this(vertex.pos.clone(), vertex.disp.clone(), id: vertex.id);
}

class Edge {
  final Vertex v;
  final Vertex u;

  Edge(this.v, this.u);
  Edge.clone(Edge edge) : this(Vertex.clone(edge.v), Vertex.clone(edge.u));

  double get d => v.pos.distanceTo(u.pos);
  Vector2 get delta => v.pos - u.pos;
}

// Let interactiveviewer determine the size of the children. Leave unconstrained and set k experimentally.
extension VectorMathHelpers on Vector2 {
  Vector2 get abs => Vector2(this.x.abs(), this.y.abs());
  Vector2 divideV(Vector2 v) => Vector2(this.x / v.x, this.y / v.y);
  Vector2 multiplyV(Vector2 v) => Vector2(this.x * v.x, this.y * v.y);
  Vector2 minS(double s) => Vector2(min(this.x, s), min(this.y, s));
}
