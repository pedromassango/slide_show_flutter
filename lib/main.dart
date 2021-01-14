import 'package:challenge/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final duration = Duration(milliseconds: 1000);

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
  String prevUrl;
  bool isFirstLoad = true;
  final _myList = GlobalKey<AnimatedListState>();

  void loadNextImage () {
    setState(() {
      isFirstLoad = false;
      prevUrl = selectedUrl;
      selectedUrl = imageUrls.removeAt(0);
      imageUrls.add(selectedUrl);
    });
    _myList.currentState.removeItem(0, (context, animation) {
      return ListIem(
        imageUrl: selectedUrl,
        animation: animation,
        close: true,
      );
    }, duration: duration);
  }

  @override
  void initState() {
    super.initState();
    selectedUrl = imageUrls.last;
    prevUrl = selectedUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(prevUrl)
          )
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;

            return Stack(
              children: [
                ExpandableItem(
                  key: ObjectKey(selectedUrl),
                  imageUrl: selectedUrl,
                  startExpanded: isFirstLoad,
                  initialPosition: Rect.fromLTRB(
                    w * .45, h * .45,
                    (w * .4) - 4, h * .2,
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
                      physics: NeverScrollableScrollPhysics(),
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.remove),
        onPressed: loadNextImage,
      ),
    );
  }
}

class ExpandableItem extends StatefulWidget {
  final String imageUrl;
  final Rect initialPosition;
  final bool startExpanded;

  const ExpandableItem({Key key,
    this.imageUrl,
    @required this.initialPosition,
    this.startExpanded = false,
  }) : super(key: key);

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
      duration: duration,
    );

    animation = RectTween(
        begin: widget.startExpanded ? Rect.fromLTRB(0, 0, 0, 0) : widget.initialPosition,
        end: Rect.fromLTRB(0, 0, 0, 0)
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Cubic(0.15, 0.85, 0.30, 0.15),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && !widget.startExpanded)
        controller.forward();
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
            ),
        ),
      ),
      builder: (context, widget) {
        final double radius = animation.value.top.clamp(0.0, 16.0);
        return Positioned(
          top: animation.value.top,
          left: animation.value.left,
          right: animation.value.right,
          bottom: animation.value.bottom,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: widget,
          ),
        );
      },
    );
  }
}

class ListIem extends StatelessWidget {
  final String imageUrl;
  final Animation animation;
  final bool close;

  const ListIem({
    @required this.imageUrl,
    @required this.animation,
    this.close = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = Size(180, 300);
    final margin = EdgeInsets.only(right: 24);

    if (close) {
      return SizeTransition(
        axis: Axis.horizontal,
        sizeFactor: animation,
        child: Container(
          width: size.width,
          height: size.height,
          margin: margin,
        ),
      );
    }
    return Container(
      width: size.width,
      height: size.height,
      margin: margin,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(.6),
              offset: Offset(12, 1)
            ),
          ],
          image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover
          ),
      ),
    );
  }
}
