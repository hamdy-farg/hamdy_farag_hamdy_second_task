import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, marginHolder, size, isLeftDirection) {
              return MouseRegion(
                onHover: (event) {},
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.ease,
                  constraints: BoxConstraints(minWidth: size ?? 48),
                  height: size ?? 48,
                  margin: EdgeInsets.only(
                      left: isLeftDirection == false ? marginHolder ?? 8 : 8,
                      right: isLeftDirection == true ? marginHolder ?? 8 : 8,
                      top: 8,
                      bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        Colors.primaries[e.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(e, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  /// [size] of container
  /// [direction] of margin
  /// [margin] holder ssize
  final Widget Function(
    T,
    double? marginHolder,
    double? size,
    bool? isLeftDirection,
  ) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  // size of placeholder of the container
  double _placeHolderSize = 40;
  // start point in dragable  in cooridnate of the screen of Y axis
  double? _startdy;
  // start point in dragable  in cooridnate of the screen of X axis
  double? _startdx;
  // Size of the Containers
  double? _size;
  // to determine which container is hoverd
  int? _hoverIndex;
  // The index of the item that will show margin space during drag.
  int? marginHolder;
  // Indicates if margin should be on the left (false) or right (true) during dragging
  bool? isLeftDirection;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (event) {
        setState(() {
          _hoverIndex = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return MouseRegion(
              onExit: (event) {
                setState(() {});
                _size = null;
              },
              onEnter: (event) {
                setState(() {
                  _hoverIndex = index;
                });
              },
              child: DragTarget<int>(onMove: (fromIndex) {
                setState(() {
                  marginHolder = index;
                  fromIndex.data <= index
                      ? isLeftDirection = true
                      : isLeftDirection = false;
                });
              }, onLeave: (fromIndex) {
                setState(() {
                  marginHolder = null;
                  isLeftDirection = null;
                });
              }, onAcceptWithDetails: (fromIndex) {
                setState(() {
                  final movedItem = _items.removeAt(fromIndex.data);
                  _items.insert(index, movedItem);
                  marginHolder = null;
                  isLeftDirection = null;
                });
              }, builder: (context, Condidate, rejected) {
                return Draggable<int>(
                    onDragCompleted: () {},
                    onDragStarted: () {
                      _startdy = null;
                      _startdx = null;
                    },
                    onDragUpdate: (onDragUpdate) {
                      _hoverIndex = null;
                      double currentDy = onDragUpdate.globalPosition.dy;
                      double currentDx = onDragUpdate.globalPosition.dx;

                      _startdy ??= currentDy;
                      _startdx ??= currentDx;
                      double yAxis = _startdy! - currentDy;
                      double xAxis = _startdx! - currentDx;

                      if (yAxis.abs() >= 45 || xAxis.abs() > 35) {
                        setState(() {
                          _placeHolderSize = 0;
                        });
                      } else {
                        setState(() {
                          _placeHolderSize = 40;
                          isLeftDirection = null;

                          marginHolder = null;
                        });
                      }
                    },
                    data: index,
                    childWhenDragging: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn,
                      height: _placeHolderSize,
                      width: _placeHolderSize,
                    ),
                    feedback: widget.builder(
                        _items[index],
                        marginHolder == index ? 40 : null,
                        _size,
                        isLeftDirection),
                    child: widget.builder(
                        _items[index],
                        marginHolder == index ? 40 : null,
                        _hoverIndex == index ? 60 : null,
                        isLeftDirection));
              }),
            );
          }),
        ),
      ),
    );
  }
}
