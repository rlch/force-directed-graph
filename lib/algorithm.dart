import 'dart:math';

import 'package:force_directed_graph/models.dart';
import 'package:vector_math/vector_math.dart';

class FruchtermanReingoldAlgorithm {
  final Vector2 dim;

  Iterable<Edge> edges;
  Iterable<Vertex> vertices;

  // Scaling constant to be determined experimentally.
  final double c = 2;
  final double vertexDiameter;

  FruchtermanReingoldAlgorithm(
    this.dim, {
    required this.edges,
    required this.vertices,
    required this.vertexDiameter,
    bool initPos = true,
  }) {
    if (!initPos) return;
    for (Vertex v in vertices) {
      v.pos = Vector2(
        (Random().nextDouble() - 0.5) * dim.x,
        (Random().nextDouble() - 0.5) * dim.y,
      );
    }
  }

  // potentially set this as a constant.
  double get k => c * sqrt(dim.x * dim.y / (vertices.length * vertexDiameter));

  // Resembles Hooke's law, where edges are considered springs.
  double _attractive(Edge edge) => pow(edge.d, 2) / k;

  // Resembles gravitational pull, with nodes simulated as particles.
  double _repulsive(Edge edge) => pow(k, 2) / ((edge.d < 0.01) ? 0.01 : edge.d);

  // Computes `iters` iterations of the Fruchterman-Reingold algorithm.
  Stream<Iterable<Vertex>> compute([int iters = 200, double t = 1]) async* {
    for (int i = 0; i < iters; i++) {
      // Calculate repulsive forces
      for (Vertex v in vertices) {
        v.disp = Vector2.zero();
        for (Vertex u in vertices) {
          if (v == u) continue;
          final Edge edge = Edge(v, u);
          v.disp += edge.delta.normalized() * _repulsive(edge);
        }
      }

      // Calculate attractive forces
      for (Edge e in edges) {
        e.v.disp -= e.delta.normalized() * _attractive(e);
        e.u.disp += e.delta.normalized() * _attractive(e);
      }

      // Constrained on `dim` and temperature `t`, adjust position of vertices.
      for (Vertex v in vertices) {
        // <=> v.pos += v.disp / v.disp.abs * min(t, v.disp.abs)
        v.pos += v.disp.normalized().multiplyV(v.disp.abs.minS(t));
        v.pos.x = v.pos.x.clamp(0, dim.x);
        v.pos.y = v.pos.y.clamp(0, dim.y);

        print(v);
      }

      // Adjust temperature using cooling function. TODO:

      yield vertices;
      await Future.delayed(Duration(milliseconds: 10));
    }
  }
}
