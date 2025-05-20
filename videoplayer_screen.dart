import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:debate/src/models/subvideos.dart';
import 'package:debate/src/models/video.dart';
import 'package:debate/src/services/subvideos_service.dart';
import 'package:debate/src/services/video_service.dart';
import 'package:debate/src/widgets/bottom_comment_sheet.dart';
import 'package:debate/src/views/screens/emojicounts_page.dart';
import 'package:debate/src/widgets/debaters_info_card.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:debate/src/views/utils/global.dart' as glb;
import 'package:timeago/timeago.dart' as timeago;

class VideoPlayerScreen extends StatefulWidget {
  final int videoId;
  final String videoTopic;
  final String videoDescription;
  final int viewsCount;
  final Video videoDetails;
  final String uri;
  final String title;
  final int debateId;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoTopic,
    required this.videoDescription,
    required this.viewsCount,
    required this.videoDetails,
    required this.uri,
    required this.title,
    required this.debateId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  // final String videoUrl = glb.backend + '/video/';
  double _aspectRatio = 16 / 9;
  bool _viewCountSent = false;
  late Timer _playbackTimer;
  late int totalViewsCount;

  List<String> emojis = [];
  bool isEmojiOverlayVisible = false;
  int selectedEmojiId = -1;
  String selectedEmoji = '';

  bool showComments = false;
  List<subvideos> getvideos = [];
  List<Video> topicVideos = [];
  void updateShowComments(bool newValue) {
    setState(() {
      showComments = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    // videoload();
    getTopicVideos();
    _videoPlayerController = VideoPlayerController.networkUrl(
      // Uri.parse('$videoUrl${widget.videoId}'),
      Uri.parse('${widget.uri}'),
      // Uri.parse(
      //     'https://dhkaa9yx39iwv.cloudfront.net/mudda/SampleVideo_1280x720_30mb.mp4'),
    )..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            // aspectRatio: _aspectRatio, // Adjust to your video's aspect ratio
            autoPlay: true,
            // looping: true,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightGreen,
            ),
          );
          _videoPlayerController.play();
        });
      });

    /* /* 1st method for viewcount increment */
          // Add a listener to monitor the playback time
          _videoPlayerController.addListener(_checkPlaybackTime); */

    /* 2nd method for viewcount increment */
    // Start the timer to check playback every 10 seconds
    _playbackTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _checkPlaybackTime();
    });

    setState(() {
      totalViewsCount = widget.viewsCount;
    });

    /* Display the emoji selected by current user(by replacing like icon) */
    displaySelectedEmoji();
    // print('videoid: ${widget.videoId}');
  }

/*   void videoload() async {
    print('Enter in videoload Function');
    try {
      final getallvideo = await fetchvideos().TopicAllvideo(widget.videoTopic);
      setState(() {
        getvideos = getallvideo;
      });
    } catch (e) {}
  } */

  Future<void> getTopicVideos() async {
    try {
      final fetchedTopicVideos =
          await VideoService.fetchTopicVideos(widget.videoTopic);
      setState(() {
        topicVideos = fetchedTopicVideos;
      });
    } catch (e) {
      print('Exception in getTopicVideos async');
    }
  }

  void _checkPlaybackTime() {
    final currentPosition = _videoPlayerController.value.position;
    if (currentPosition.inSeconds >= 30 && !_viewCountSent) {
      _playbackTimer.cancel();
      VideoService().sendViewCountRequest(context, widget.videoId);
      setState(() {
        _viewCountSent = true;
      });
    }
  }

  /* Function to pause the video */
  void _pauseVideo() {
    _chewieController.pause();
  }

  @override
  void dispose() {
    if (_playbackTimer.isActive) {
      _playbackTimer.cancel();
    }
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> getEmojisFromApi() async {
    try {
      final fetchedEmojis = await VideoService().getEmojis();
      setState(() {
        emojis = fetchedEmojis;
      });
    } catch (e) {
      print('Error fetching emojis: $e');
    }
  }

  void toggleEmojiOverlay() async {
    setState(() {
      isEmojiOverlayVisible = !isEmojiOverlayVisible;
    });
  }

  Future<void> displaySelectedEmoji() async {
    try {
      Map<String, dynamic> fetchedEmojiDetails =
          await VideoService().fetchSelectedEmoji(widget.videoId);
      setState(() {
        selectedEmoji = fetchedEmojiDetails['name'];
        selectedEmojiId = fetchedEmojiDetails['id'];
      });
    } catch (e) {
      print('Error in displaySelectedEmoji(): $e');
    }
  }

  Future<void> fetchEmojiCounts() async {
    try {
      final emojiCounts =
          await VideoService().emojiCountRefresh(widget.videoId);
      setState(() {
        widget.videoDetails.emojiCounts = emojiCounts;
      });
    } catch (e) {
      throw Exception('Error in emoji count increment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoPlayerHeight = screenWidth / _aspectRatio;

    return GestureDetector(
      onTap: () {
        if (isEmojiOverlayVisible) {
          setState(() {
            isEmojiOverlayVisible = false;
          });
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              _videoPlayerController.value.isInitialized
                  ? Container(
                      width: double.infinity,
                      height: videoPlayerHeight,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey,
                      height: 230,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://www.saga.co.uk/contentlibrary/saga/publishing/verticals/technology/internet/communications/youtube-1.png'),
                                ),
                                title: Text(
                                  widget.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.videoTopic}',
                                        ),
                                        Text(
                                          '  |  ',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          '$totalViewsCount views',
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                        onTap: () {
                                          _pauseVideo(); /* pause the video before navigating to another page */
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EmojiCountsPage(
                                                emojiCountsDetail: widget
                                                    .videoDetails.emojiCounts,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye,
                                              color: Colors.blue,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              'Likes',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                          if (isEmojiOverlayVisible && emojis.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  child: Wrap(
                                    spacing: 14,
                                    children: emojis.map((emoji) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (selectedEmoji.isEmpty) {
                                            await VideoService().addEmoji(
                                                emoji, widget.videoId);
                                          } else {
                                            await VideoService().updateEmoji(
                                                emoji, selectedEmojiId);
                                          }
                                          await displaySelectedEmoji();
                                          toggleEmojiOverlay();
                                          await fetchEmojiCounts();
                                        },
                                        child: Text(
                                          emoji,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!showComments)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (glb.accessToken != "") {
                                      await getEmojisFromApi();
                                      toggleEmojiOverlay();
                                    } else {
                                      glb.showLoginAlert(context);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: selectedEmoji.isNotEmpty
                                            ? Text(
                                                selectedEmoji,
                                                style: TextStyle(fontSize: 18),
                                              )
                                            : Icon(Icons.thumb_up_alt_outlined),
                                      ),
                                      Text('Like',
                                          style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    updateShowComments(true);
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Icon(Icons.comment_outlined),
                                      ),
                                      Text('Comment',
                                          style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print('Share button pressed');
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Icon(Icons.send_outlined),
                                      ),
                                      Text('Share',
                                          style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      showComments
                          ? BottomSheetForComment(
                              videoId: widget.videoId,
                              showComments: showComments,
                              onUpdateShowComments: updateShowComments,
                            )
                          : Column(
                              children: [
                                DebatersInfoCard(
                                  debateId: widget.debateId,
                                  videoId: widget.videoId,
                                  topicname: widget.videoTopic,
                                  videoDescription: widget.videoDescription,
                                  viewsCount: widget.viewsCount,
                                  videoDetails: widget.videoDetails,
                                  onPauseVideo:
                                      _pauseVideo, // Pass the callback
                                ),
                                //++++++++++++++++ VideoListPage(topicName: widget.videoTopic)
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Videos of ${widget.videoTopic}',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Column(
                                    children:
                                        /* getvideos.map((userdata) {
                                    return Card(
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoPlayerScreen(
                                                              videoId: widget
                                                                  .videoId,
                                                              videoTopic: widget
                                                                  .videoTopic,
                                                              videoDescription:
                                                                  widget
                                                                      .videoDescription,
                                                              viewsCount: widget
                                                                  .viewsCount,
                                                              videoDetails: widget
                                                                  .videoDetails)));
                                            },
                                            child: Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        'Topic Name: ${userdata.topic}'),
                                                    Text('Debate: '),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(), */
                                        topicVideos.map((video) {
                                  DateTime createdDate =
                                      DateTime.parse(video.createdAt);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerScreen(
                                            videoId: video.id,
                                            videoTopic: video.topic,
                                            videoDescription: video.description,
                                            viewsCount: video.viewsCount!,
                                            videoDetails: video,
                                            uri: video.uri,
                                            title: video.title,
                                            debateId: video.debateId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 230,
                                          width: double.infinity,
                                          decoration: video.thumbnail != null &&
                                                  video.thumbnail!.isNotEmpty
                                              ? BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      video.thumbnail!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : BoxDecoration(
                                                  color: Colors.grey.shade400,
                                                ),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                'https://www.saga.co.uk/contentlibrary/saga/publishing/verticals/technology/internet/communications/youtube-1.png'),
                                          ),
                                          title: Text(
                                            (video.title),
                                          ),
                                          subtitle: Text(
                                              '${video.topic} | ${video.viewsCount} views | ${timeago.format(createdDate)}'),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
