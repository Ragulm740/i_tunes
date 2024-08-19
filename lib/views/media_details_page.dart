import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaDetailPage extends StatelessWidget {
  final dynamic media;

  const MediaDetailPage({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: Text('Description', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  media['artworkUrl100'] != null
                      ? Image.network(
                          media['artworkUrl100'],
                          
                        )
                      : Container(
                         
                          color: Colors.grey,
                        ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media['trackName'] ?? 'No Title',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        media['artistName'] ?? 'Unknown Artist',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        media['primaryGenreName'] ?? 'No Genre',
                        style: TextStyle(color: Colors.yellow, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 16),
              _buildPreview(media['previewUrl']),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                media['longDescription'] ?? 'No Description',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(String? url) {
    if (url == null) {
      return Container();
    }

    // Check the media type based on the URL or metadata
    if (url.endsWith('.mp4')) {
      // Video URL
      return _buildVideoPlayer(url);
    } else if (url.endsWith('.mp3') || url.endsWith('.wav')) {
      // Audio URL
      return _buildAudioPlayer(url);
    } else {
      // If URL type is not recognized, use a link button to open it in a browser
      return TextButton(
        onPressed: () => _launchUrl(url),
        child: Text(
          'Open Preview',
          style: TextStyle(color: Colors.blue),
        ),
      );
    }
  }

  Widget _buildVideoPlayer(String url) {
    final VideoPlayerController _controller = VideoPlayerController.network(url);

    return FutureBuilder(
      future: _controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildAudioPlayer(String url) {
    // This example uses a simple TextButton for audio preview.
    // You may want to use a package like `just_audio` for better audio control.
    return TextButton(
      onPressed: () => _launchUrl(url),
      child: Text(
        'Play Audio Preview',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  // Future<void> _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
}
