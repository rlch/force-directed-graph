import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:force_directed_graph/algorithm.dart';
import 'package:force_directed_graph/models.dart';
import 'package:vector_math/vector_math.dart' as vec;

class ForceDirectedGraph extends StatefulWidget {
  final double width;
  final double height;

  final List<Edge> edges;
  final List<Vertex> vertices;

  const ForceDirectedGraph({
    Key? key,
    required this.width,
    required this.height,
    required this.edges,
    required this.vertices,
  }) : super(key: key);

  @override
  _ForceDirectedGraphState createState() => _ForceDirectedGraphState();
}

class _ForceDirectedGraphState extends State<ForceDirectedGraph> {
  Stream<List<Vertex>>? network;

  final GlobalKey networkContainer = GlobalKey();
  final double vertexDiameter = 30;
  String? vertexSelected;
  bool isDragging = false;
  bool shouldLink = false;

  @override
  void initState() {
    super.initState();
    resetAlgo(initPos: true);
  }

  void resetAlgo({bool initPos = false}) async =>
      network = FruchtermanReingoldAlgorithm(
        vec.Vector2(
          widget.width - vertexDiameter,
          widget.height - vertexDiameter,
        ),
        edges: widget.edges,
        vertices: widget.vertices,
        vertexDiameter: vertexDiameter,
        initPos: initPos,
      ).compute().map((event) => event.toList());

  void addVertex(Vertex vertex) {
    setState(() {
      widget.vertices.add(vertex);
      if (vertexSelected == null) {
        vertexSelected = vertex.id;
      } else {
        widget.edges.add(Edge(
            vertex, widget.vertices.firstWhere((v) => v.id == vertexSelected)));
      }
      print(widget.edges);
    });
    resetAlgo();
  }

  void addEdge(Edge edge) {
    setState(() => widget.edges.add(edge));
    resetAlgo();
  }

  @override
  Widget build(BuildContext context) {
    final vertexWidget = Container(
      width: vertexDiameter,
      height: vertexDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => shouldLink = !shouldLink),
        label: Text(shouldLink ? 'Stop' : 'Link other node'),
        icon: Icon(Icons.link),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            key: networkContainer,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: StreamBuilder<List<Vertex>>(
                stream: network,
                builder: (context, snap) {
                  final vertices = snap.data;
                  return Stack(
                    children: [
                      ...widget.edges.map((e) =>
                          CustomPaint(painter: EdgeArrow(e, vertexDiameter))),
                      ...(vertices ?? []).map((v) {
                        return Positioned(
                          left: v.pos.x,
                          top: v.pos.y,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => shouldLink && vertexSelected != v.id
                                      ? addEdge(Edge(
                                          v,
                                          widget.vertices.firstWhere(
                                              (v) => v.id == vertexSelected),
                                        ))
                                      : vertexSelected = v.id),
                              child: Container(
                                width: vertexDiameter,
                                height: vertexDiameter,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: vertexSelected == v.id
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      IgnorePointer(
                        ignoring: !isDragging,
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            if (candidateData.isNotEmpty) {
                              return Container(
                                color: Colors.blue.withOpacity(0.1),
                              );
                            }
                            return Container(color: Colors.transparent);
                          },
                          onAcceptWithDetails: (details) {
                            final renderBox = networkContainer.currentContext!
                                .findRenderObject() as RenderBox;
                            final Offset localOffset =
                                renderBox.globalToLocal(details.offset);
                            addVertex(Vertex(
                              vec.Vector2(
                                localOffset.dx,
                                localOffset.dy,
                              ),
                              vec.Vector2.zero(),
                            ));
                          },
                          onWillAccept: (_) => true,
                        ),
                      ),
                    ],
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Draggable<String>(
                feedback: vertexWidget,
                child: vertexWidget,
                data: '',
                onDragStarted: () => setState(() => isDragging = true),
                onDragEnd: (_) => setState(() => isDragging = false),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class EdgeArrow extends CustomPainter {
  final Edge edge;
  final double vertexDiameter;

  const EdgeArrow(this.edge, this.vertexDiameter);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(
          edge.v.pos.x + vertexDiameter / 2, edge.v.pos.y + vertexDiameter / 2),
      Offset(
          edge.u.pos.x + vertexDiameter / 2, edge.u.pos.y + vertexDiameter / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
