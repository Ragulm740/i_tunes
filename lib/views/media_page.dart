import 'package:flutter/material.dart';
import 'package:i_tunes/views/media_details_page.dart';

class MediaPage extends StatefulWidget {
  final List<dynamic> searchResults;
  const MediaPage({super.key, required this.searchResults});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>  with TickerProviderStateMixin {


  TabController
  ? _controller;

  // this will control the animation when a button changes from an off state to an on state
  AnimationController? _animationControllerOn;

  // this will control the animation when a button changes from an on state to an off state
  AnimationController? _animationControllerOff;

  // this will give the background color values of a button when it changes to an on state
  Animation? _colorTweenBackgroundOn;
  Animation? _colorTweenBackgroundOff;

  // this will give the foreground color values of a button when it changes to an on state
  Animation? _colorTweenForegroundOn;
  Animation? _colorTweenForegroundOff;

  // when swiping, the _controller.index value only changes after the animation, therefore, we need this to trigger the animations and save the current index
  int _currentIndex = 0;

  // saves the previous active tab
  int _prevControllerIndex = 0;

  // saves the value of the tab animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  double _aniValue = 0.0;

  // saves the previous value of the tab animation. It's used to figure the direction of the animation
  double _prevAniValue = 0.0;

  // these will be our tab icons. You can use whatever you like for the content of your buttons
  List _icons = [
    "List Layout",
   "Grid Layout"
  
  ];

  // active button's foreground color
  Color _foregroundOn = Colors.white;
  Color _foregroundOff = Colors.white;

  // active button's background color
  Color _backgroundOn = Colors.grey;
  Color? _backgroundOff = const Color.fromARGB(255, 36, 36, 36);

  // scroll controller for the TabBar
  ScrollController _scrollController = new ScrollController();

  // this will save the keys for each Tab in the Tab Bar, so we can retrieve their position and size for the scroll controller
  List _keys = [];

  // regist if the the button was tapped
  bool _buttonTap = false;
@override
  void initState() {
    super.initState();

    for (int index = 0; index < _icons.length; index++) {
      // create a GlobalKey for each Tab
      _keys.add(new GlobalKey());
    }

    // this creates the controller with 6 tabs (in our case)
    _controller = TabController(vsync: this, length: _icons.length);
    // this will execute the function every time there's a swipe animation
    _controller!.animation!.addListener(_handleTabAnimation);
    // this will execute the function every time the _controller.index value changes
    _controller!.addListener(_handleTabChange);

    _animationControllerOff =
        AnimationController(vsync: this, duration: Duration(milliseconds: 75));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff!.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: _backgroundOn, end: _backgroundOff)
            .animate(_animationControllerOff!);
    _colorTweenForegroundOff =
        ColorTween(begin: _foregroundOn, end: _foregroundOff)
            .animate(_animationControllerOff!);

    _animationControllerOn =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOn!.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn!);
    _colorTweenForegroundOn =
        ColorTween(begin: _foregroundOff, end: _foregroundOn)
            .animate(_animationControllerOn!);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }


  void _navigateToDetailPage(dynamic media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaDetailPage(media: media),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color set to black
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'iTunes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body:  Column(
        children: [
          Container(
            height: 54.0,
            margin: EdgeInsets.all(10),
            // this generates our tabs buttons
            child: ListView.builder(
              // this gives the TabBar a bounce effect when scrolling farther than its size
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              // make the list horizontal
              scrollDirection: Axis.horizontal,
              // number of tabs
              itemCount: _icons.length,
              itemBuilder: (BuildContext context, int index) {
          return Padding(
            // each button's key
            key: _keys[index],
            // padding for the buttons
            padding: EdgeInsets.all(6.0),
            child: ButtonTheme(
              child: AnimatedBuilder(
                animation: _colorTweenBackgroundOn!,
                builder: (context, child) => SizedBox(
                  width:  190,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _getBackgroundColor(index), // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0), // Increase the horizontal padding
                    ),
                    onPressed: () {
                      setState(() {
                        _buttonTap = true;
                        // trigger the controller to change between Tab Views
                        _controller!.animateTo(index);
                        // set the current index
                        _setCurrentIndex(index);
                        // scroll to the tapped button (needed if we tap the active button and it's not on its position)
                        _scrollTo(index);
                      });
                    },
                    child: Text(
                      // get the icon
                      _icons[index],
                      // get the color of the icon (dependent of its state)
                      style: TextStyle(
                        color: _getForegroundColor(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
              },
            ),
          ),
           Expanded(
             child: TabBarView(
                     controller: _controller,
                     children: [
                       Padding(
              padding: const EdgeInsets.fromLTRB(4,8,4,8),
              child: _buildListView(),
                       ), // ListView Tab
                       Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGridView(),
                       ), // GridView Tab
                     ],
                   ),
           ),
        ],
      ),
      
     
    );
  }

  Widget _buildListView() {
    return widget.searchResults.isEmpty
        ? Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Colors.white),
            ),
          )
        : ListView.builder(
            itemCount: widget.searchResults.length,
            itemBuilder: (context, index) {
              final media = widget.searchResults[index];
              return Card(
                color: Colors.grey[900],
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  leading: media['artworkUrl100'] != null
                      ? Image.network(
                          media['artworkUrl100'],
                        
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey,
                        ),
                  title: Text(
                    media['trackName'] ?? 'No Title',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    media['artistName'] ?? 'Unknown Artist',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap:()=> _navigateToDetailPage(media),
                ),
              );
            },
          );
  }

  Widget _buildGridView() {
    return widget.searchResults.isEmpty
        ? Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Colors.white),
            ),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns for grid
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.searchResults.length,
            itemBuilder: (context, index) {
              final media = widget.searchResults[index];
              return GestureDetector(
                onTap:()=> _navigateToDetailPage(media),
                child: Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        media['artworkUrl100'] != null
                            ? Image.network(
                                media['artworkUrl100'],
                                height: 100,
                                width: 100,
                              )
                            : Container(
                                height: 100,
                                width: 100,
                                color: Colors.grey,
                              ),
                        SizedBox(height: 8),
                        Text(
                          media['trackName'] ?? 'No Title',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            media['artistName'] ?? 'Unknown Artist',
                            style: TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = _controller!.animation!.value;

    // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  _handleTabChange() {
    // if a button was tapped, change the current index
    if (_buttonTap) _setCurrentIndex(_controller!.index);

    // this resets the button tap
    if ((_controller!.index == _prevControllerIndex) ||
        (_controller!.index == _aniValue.round())) _buttonTap = false;

    // save the previous controller index
    _prevControllerIndex = _controller!.index;
  }

  _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      setState(() {
        // change the index
        _currentIndex = index;
      });

      // trigger the button animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    // reset the animations so they're ready to go
    _animationControllerOn!.reset();
    _animationControllerOff!.reset();

    // run the animations!
    _animationControllerOn!.forward();
    _animationControllerOff!.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;
    
    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _keys[_icons.length - 1].currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      // if it's active button
      return _colorTweenBackgroundOn!.value;
    } else if (index == _prevControllerIndex) {
      // if it's the previous active button
      return _colorTweenBackgroundOff!.value;
    } else {
      // if the button is inactive
      return _backgroundOff;
    }
  }

  _getForegroundColor(int index) {
    // the same as the above
    if (index == _currentIndex) {
      return _colorTweenForegroundOn!.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff!.value;
    } else {
      return _foregroundOff;
    }
  }
}
