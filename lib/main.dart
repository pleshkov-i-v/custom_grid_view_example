import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const CutomGridViewExampleApp());

class CutomGridViewExampleApp extends StatefulWidget {
  const CutomGridViewExampleApp({super.key});

  @override
  State<CutomGridViewExampleApp> createState() =>
      _CutomGridViewExampleAppState();
}

class _CutomGridViewExampleAppState extends State<CutomGridViewExampleApp> {
  late final List<int> headers;
  late List<Object> items;
  late List<GridViewItemType> gridViewItemsType;
  late CustomGridDelegate gridDelegate;
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    headers = [0, 7, 25, 51, 100, 150, 498, 700, 5908];
    items = List<Object>.generate(
      10000,
      (int index) => headers.contains(index) ? 'header $index' : index,
    );
    gridViewItemsType = items
        .map(
          (e) => e is String ? GridViewItemType.header : GridViewItemType.item,
        )
        .toList();
    gridDelegate = CustomGridDelegate(
      itemMaxCrossAxisExtent: 240.0,
      itemMainAxisExtent: 40.0,
      itemCrossAxisStacing: 12.0,
      itemMainAxisStacing: 12.0,
      titleMainAxisExtent: 80.0,
      titleMainAxisBeforeSpacing: 15.0,
      titleMainAxisAfterSpacing: 5.0,
      itemTypes: gridViewItemsType,
    );
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            if (gridDelegate.geometries != null) {
              final SliverGridGeometry geometry =
                  gridDelegate.geometries![5908];
              scrollController.animateTo(
                geometry.scrollOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8.0,
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12.0),
              gridDelegate: gridDelegate,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                if (index > items.length - 1) return null;
                final Object item = items[index];

                return Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    gradient: const RadialGradient(
                      colors: <Color>[Color(0x0F88EEFF), Color(0x2F0099BB)],
                    ),
                  ),
                  child: item is String
                      ? Center(child: Text(item))
                      : Center(child: Text('Item $index')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum GridViewItemType { header, item }

class CustomGridDelegate extends SliverGridDelegate {
  CustomGridDelegate({
    required this.itemMaxCrossAxisExtent,
    required this.itemMainAxisExtent,
    required this.itemCrossAxisStacing,
    required this.itemMainAxisStacing,
    required this.titleMainAxisExtent,
    required this.titleMainAxisBeforeSpacing,
    required this.titleMainAxisAfterSpacing,
    required this.itemTypes,
  });

  final double itemMaxCrossAxisExtent;
  final double itemMainAxisExtent;
  final double itemCrossAxisStacing;
  final double itemMainAxisStacing;
  final double titleMainAxisExtent;
  final double titleMainAxisBeforeSpacing;
  final double titleMainAxisAfterSpacing;
  final List<GridViewItemType> itemTypes;
  List<SliverGridGeometry>? geometries;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    int itemCrossAxisCount =
        (constraints.crossAxisExtent /
                (itemMaxCrossAxisExtent + itemCrossAxisStacing))
            .ceil();
    // Ensure a minimum count of 1, can be zero and result in an infinite extent
    // below when the window size is 0.
    itemCrossAxisCount = math.max(1, itemCrossAxisCount);
    final double usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent -
          itemCrossAxisStacing * (itemCrossAxisCount - 1),
    );
    final double evaluatedItemsCrossAxisExtent =
        usableCrossAxisExtent / itemCrossAxisCount;
    final List<SliverGridGeometry> localGeometries = <SliverGridGeometry>[];
    int indexInRow = 0;

    double currentMainAxisOffset = 0.0;
    double currentCrossAxisOffset = 0.0;
    for (int i = 0; i < itemTypes.length; i++) {
      final GridViewItemType item = itemTypes[i];
      switch (item) {
        case GridViewItemType.header:
          indexInRow = 0;
          currentCrossAxisOffset = 0.0;
          localGeometries.add(
            SliverGridGeometry(
              scrollOffset: currentMainAxisOffset, // "y"
              crossAxisOffset: currentCrossAxisOffset, // "x"
              mainAxisExtent: titleMainAxisExtent, // "height"
              crossAxisExtent: constraints.crossAxisExtent, // "width"
            ),
          );
          currentMainAxisOffset +=
              titleMainAxisExtent + titleMainAxisAfterSpacing;
          break;
        case GridViewItemType.item:
          if (indexInRow == itemCrossAxisCount) {
            // start new row
            indexInRow = 0;
            currentCrossAxisOffset = 0.0;
            currentMainAxisOffset += itemMainAxisExtent + itemMainAxisStacing;
          }

          localGeometries.add(
            SliverGridGeometry(
              scrollOffset: currentMainAxisOffset, // "y"
              crossAxisOffset: currentCrossAxisOffset, // "x"
              mainAxisExtent: itemMainAxisExtent, // "height"
              crossAxisExtent: evaluatedItemsCrossAxisExtent, // "width"
            ),
          );

          if ((i + 1 < itemTypes.length) &&
              (itemTypes[i + 1] == GridViewItemType.header)) {
            // end of section. add spacing
            currentMainAxisOffset +=
                itemMainAxisExtent + titleMainAxisBeforeSpacing;
          } else {
            currentCrossAxisOffset +=
                itemCrossAxisStacing + evaluatedItemsCrossAxisExtent;
            indexInRow++;
          }
          break;
      }
    }

    geometries = localGeometries;
    return CustomGridLayout(
      crossAxisItemsCount: itemCrossAxisCount,
      itemCrossAxisExtent: evaluatedItemsCrossAxisExtent,
      titleCrossAxisExtent: constraints.crossAxisExtent,
      geometries: localGeometries,
      titleMainAxisExtentExtent: titleMainAxisExtent,
      itemMainAxisExtentExtent: itemMainAxisExtent,
    );
  }

  @override
  bool shouldRelayout(CustomGridDelegate oldDelegate) {
    return oldDelegate.itemMaxCrossAxisExtent != itemMaxCrossAxisExtent ||
        oldDelegate.itemMainAxisExtent != itemMainAxisExtent ||
        oldDelegate.titleMainAxisExtent != titleMainAxisExtent ||
        oldDelegate.itemCrossAxisStacing != itemCrossAxisStacing ||
        oldDelegate.itemMainAxisStacing != itemMainAxisStacing ||
        oldDelegate.itemTypes != itemTypes;
  }
}

class CustomGridLayout extends SliverGridLayout {
  const CustomGridLayout({
    required this.crossAxisItemsCount,
    required this.itemCrossAxisExtent,
    required this.titleCrossAxisExtent,
    required this.titleMainAxisExtentExtent,
    required this.itemMainAxisExtentExtent,
    required this.geometries,
  }) : assert(crossAxisItemsCount > 0);

  final int crossAxisItemsCount;
  final double itemCrossAxisExtent;
  final double titleCrossAxisExtent;
  final double titleMainAxisExtentExtent;
  final double itemMainAxisExtentExtent;
  final List<SliverGridGeometry> geometries;

  @override
  double computeMaxScrollOffset(int childCount) {
    final SliverGridGeometry geometry = geometries[childCount - 1];
    return geometry.scrollOffset + geometry.mainAxisExtent;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    return geometries[index];
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final int result = geometries.indexWhere(
      (SliverGridGeometry element) => element.scrollOffset >= scrollOffset,
    );
    return result;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    double greaterScrollOffset = 0.0;
    int result = 0;
    for (int i = 0; i < geometries.length; i++) {
      final double itemOffset = geometries[i].scrollOffset;

      if (scrollOffset > itemOffset) {
        continue;
      }
      if (result == 0) {
        greaterScrollOffset = itemOffset;
        result = i;
        continue;
      }
      if (greaterScrollOffset == itemOffset) {
        //next item in same line
        // update result
        result = i;
        continue;
      }

      // next line started
      // return last index from previous line
      break;
    }
    return result > 0 ? result : geometries.length - 1;
  }
}
