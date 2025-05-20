/* PROPERLY WORKING */
// homepage for use widget
import 'package:debate/src/models/video.dart';
import 'package:debate/src/services/video_service.dart';
import 'package:debate/src/views/screens/videoplayer_screen.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoListPage extends StatefulWidget {
  final String topicName;

  const VideoListPage({
    super.key,
    required this.topicName,
  });
  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Video> videos = [];
  bool isLoading = true; // Add a loading state variable
  bool isVideosAvailable = true;

  @override
  void initState() {
    print('initState called');
    super.initState();
    fetchVideos(widget.topicName);
  }

  @override
  void didUpdateWidget(VideoListPage oldWidget) {
    print('didUpdateWidget called');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicName != widget.topicName) {
      fetchVideos(widget.topicName);
    }
  }

  /* Fetching videos from DB */
  Future<void> fetchVideos(String topicName) async {
    print('fetchVideos called');
    try {
      List<Video> fetchedVideos;
      if (topicName == 'All') {
        fetchedVideos = await VideoService.fetchAllVideos();
      } else {
        fetchedVideos = await VideoService.fetchTopicVideos(topicName);
      }

      setState(() {
        videos = fetchedVideos;
        isLoading = false;
        if (fetchedVideos.isNotEmpty) {
          isVideosAvailable = true;
        } else {
          isVideosAvailable = false;
        }
      });
    } catch (e) {
      // Handle error, show error message, etc.
      print('Error fetching videos: $e');
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error too.
      });

      /* If video is not available for a particular topic then it returns SC 404, 
      so set isVIdeosAvailable variable to false  */
      if (e.toString().contains('404')) {
        setState(() {
          isVideosAvailable = false;
        });
      }
    }
  }

  /* ---------------Overriding setState()--------------- */
  @override
  void setState(VoidCallback fn) {
    print('overrided setstate');
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('building videolistpage');
    return isLoading
        ? const Center(
            child:
                CircularProgressIndicator(), // Show loading indicator while videos are fetched.
          )
        /* If video is available for particular topic show videos or else msg as, 'No videos available'  */
        : isVideosAvailable
            ? ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  Video video = videos[index];
                  DateTime createdDate = DateTime.parse(video.createdAt);
                  // String formattedCreateDate =
                  //     DateFormat('dd-MM-yyyy').format(createdDate);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
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
                        Stack(
                          children: [
                            Container(
                              height: 230,
                              width: double.infinity,
                              /* If thumbnail is not null and not empty, it sets a BoxDecoration with a DecorationImage.
                              If null or empty, it sets a BoxDecoration with a grey background color */
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
                              /* If thumbnail is null or empty, the child property displays a centered icon to indicate that no image is available */
                              child: video.thumbnail == null ||
                                      video.thumbnail!.isEmpty
                                  ? Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  : null,
                            ),
                            /* Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          children: [
                                            Text(
                                              'Debate Name : ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${video.title}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            Text(
                                              'Parent Name : ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${video.topic}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            Text(
                                              'Debaters : ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Waiting, for, backend, data',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                            ), */
                          ],
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade400,
                            /* If thumbnail is not null and not empty, load the image
                            and If thumbnail is null or empty, backgroundImage is set to null, meaning no image will be loaded.*/
                            backgroundImage: video.thumbnail != null &&
                                    video.thumbnail!.isNotEmpty
                                ? NetworkImage(
                                    video.thumbnail!,
                                  )
                                : null,
                            /* If thumbnail is null or empty, an Icon is displayed inside the CircleAvatar.
                            If thumbnailUrl is valid, child is set to null, meaning no icon is displayed,
                            allowing the NetworkImage to be shown as the background */
                            child: video.thumbnail == null ||
                                    video.thumbnail!.isEmpty
                                ? Icon(
                                    Icons.image,
                                    color: Colors.grey.shade600,
                                  )
                                : null,
                          ),
                          title: Text(video.title),
                          subtitle: Wrap(
                            spacing: 4,
                            children: [
                              Text(video.topic),

                              Text(
                                '|',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              Text('${video.viewsCount} views'),

                              Text(
                                '|',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              Text(timeago.format(createdDate)),
                              // Text('${formattedCreateDate}'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  'No videos available',
                  style: TextStyle(fontSize: 15),
                ),
              );
  }
}

/* -------------------------------Testing (Pagination) ------------------------------------- */

/* import 'package:debate/src/models/video.dart';
import 'package:debate/src/services/video_service.dart';
import 'package:debate/src/views/screens/videoplayer_screen.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoListPage extends StatefulWidget {
  final String topicName;

  const VideoListPage({
    super.key,
    required this.topicName,
  });
  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Video> videos = [];
  bool isLoading = true; // Add a loading state variable
  bool isVideosAvailable = true;

  final controller = ScrollController();
  int page = 1;
  int pageSize = 6;
  bool hasMore = true;

  @override
  void initState() {
    print('initState called');
    super.initState();
    fetchVideos(widget.topicName);

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetchVideos(widget.topicName);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void didUpdateWidget(VideoListPage oldWidget) {
    print('didUpdateWidget called');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicName != widget.topicName) {
      fetchVideos(widget.topicName); // Fetch new videos if the topic changes
    }
  }

  /* Fetching videos from DB */
  Future<void> fetchVideos(String topicName) async {
    print('fetchVideos called: $topicName');
    try {
      List<Video> fetchedVideos;
      if (topicName == 'All') {
        fetchedVideos = await VideoService.fetchAllVideos(page, pageSize);
      } else {
        fetchedVideos = await VideoService.fetchTopicVideos(topicName);
      }

      setState(() {
        page++;
        if (videos.length < pageSize) {
          hasMore = false;
        }
        videos.addAll(fetchedVideos);
        isLoading = false; // Set isLoading to false when videos are fetched.
        if (fetchedVideos.isNotEmpty) {
          isVideosAvailable = true;
        } else {
          isVideosAvailable = false;
        }
      });
    } catch (e) {
      // Handle error, show error message, etc.
      print('Error fetching videos: $e');
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error too.
      });

      /* If video is not available for a particular topic then it returns SC 404, 
      so set isVIdeosAvailable variable to false  */
      if (e.toString().contains('404')) {
        setState(() {
          isVideosAvailable = false;
        });
      }
    }
  }

  /* ---------------Overriding setState()--------------- */
  // @override
  // void setState(VoidCallback fn) {
  //   print('overrided setstate');
  //   if (mounted) {
  //     super.setState(fn);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print('building videolistpage');
    return isVideosAvailable
        ? ListView.builder(
            itemCount: videos.length + 1,
            itemBuilder: (context, index) {
              if (index < videos.length) {
                Video video = videos[index];
                DateTime createdDate = DateTime.parse(video.createdAt);
                // String formattedCreateDate =
                //     DateFormat('dd-MM-yyyy').format(createdDate);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoId: video.id,
                          videoTopic: video.topic,
                          videoDescription: video.description,
                          viewsCount: video.viewsCount!,
                          videoDetails: video,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        // color: Colors.grey,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          image: DecorationImage(
                            image: NetworkImage(
                              video.thumbnail ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            video.thumbnail ?? '',
                          ),
                        ),
                        title: Text(video.description),
                        subtitle: Wrap(
                          spacing: 4,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(video.topic),

                            Text(
                              '|',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            Text('${video.viewsCount} views'),

                            Text(
                              '|',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            Text(timeago.format(createdDate)),
                            // Text('${formattedCreateDate}'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: hasMore
                        ? CircularProgressIndicator()
                        : Text('No more data to load'),
                  ),
                );
              }
            },
          )
        : const Center(
            child: Text(
              'No videos available',
              style: TextStyle(fontSize: 15),
            ),
          );
  }
} */
