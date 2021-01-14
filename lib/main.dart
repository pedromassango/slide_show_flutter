import 'package:challenge/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
  with SingleTickerProviderStateMixin {

  final List<String> imageUrls = ImageUtils.imageUrls;
  String selectedUrl;
  int currentIndex = 0;
  final _myList = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    selectedUrl = imageUrls.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          return Stack(
            children: [
              ExpandableItem(
                key: ObjectKey(selectedUrl),
                imageUrl: selectedUrl,
                initialPosition: Rect.fromLTRB(
                  w * .45, h * .45,
                  w * .56, h * .2,
                ),
              ),
              Positioned(
                left: w * .45,
                top: h * .45,
                right: 0,
                bottom: h * .2,
                child: SizedBox(
                  height: 240,
                  child: AnimatedList(
                    key: _myList,
                    initialItemCount: imageUrls.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index, Animation animation) {
                      return ListIem(
                        imageUrl: imageUrls[index],
                        animation: animation,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.remove),
        onPressed: () {
            _myList.currentState.removeItem(0, (context, animation) {
              return ListIem(imageUrl: selectedUrl, animation: animation);
            }, duration: Duration(milliseconds: 50));
          setState(() {
            selectedUrl = imageUrls.removeAt(0);
            imageUrls.add(selectedUrl);
          });
        },
      ),
    );
  }
}

class ExpandableItem extends StatefulWidget {
  final String imageUrl;
  final Rect initialPosition;

  const ExpandableItem({Key key, this.imageUrl, @required this.initialPosition}) : super(key: key);

  @override
  _ExpandableItemState createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem>
  with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Rect> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    animation = RectTween(
        begin: widget.initialPosition,
        end: Rect.fromLTRB(0, 0, 0, 0)
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
            )
        ),
      ),
      builder: (context, widget) {
        final double radius = animation.value.width < 5 ? 0.0 : 16;
        return AnimatedPositioned(
          top: animation.value.top,
            left: animation.value.left,
            right: animation.value.right,
            bottom: animation.value.bottom,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: widget,
            ),
            duration: Duration(milliseconds: 0),
        );
      },
    );
  }
}


class ListIem extends StatelessWidget {
  final String imageUrl;
  final Animation animation;

  const ListIem({
    @required this.imageUrl,
    @required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 300,
      margin: EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover
        )
      ),
    );
  }
}

