import 'package:flutter/material.dart';
import 'package:force_directed_graph/visualization.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForceDirectedGraph(
        width: 500,
        height: 500,
        edges: [],
        vertices: [],
      ),
    ),
  );
}
