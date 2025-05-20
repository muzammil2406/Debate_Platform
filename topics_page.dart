/* import 'package:debate/src/models/topic.dart';
import 'package:debate/src/services/topic_service.dart';
import 'package:debate/src/views/screens/create_topic.dart';
import 'package:debate/src/views/screens/schedule_debate.dart';
import 'package:flutter/material.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Topic> topicsObject = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllTopics();
  }

  /* Fetching all topics from DB */
  Future<void> fetchAllTopics() async {
    try {
      final fetchedTopics = await TopicService().fetchTopics();
      setState(() {
        topicsObject = fetchedTopics;
        isLoading = false;
      });
    } catch (e) {
      // throw Exception('Topics fetching failed');
      print('Exception in topics page: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        actions: [
          IconButton(
            onPressed: () {
              if (glb.accessToken != "") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTopic(),
                  ),
                );
              } else {
                glb.showLoginAlert(context);
              }
            },
            icon: Icon(
              Icons.add_box_rounded,
              size: 30,
            ),
          )
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              'Select or Create a topic to schedule a debate',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : topicsObject.isNotEmpty
                    ? ListView.builder(
                        itemCount: topicsObject.length,
                        itemBuilder: (context, index) {
                          final eachTopicObj = topicsObject[index];
                          return InkWell(
                            onTap: () {
                              if (glb.accessToken != "") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ScheduleDebate(
                                            topicName: eachTopicObj.name)));
                              } else {
                                glb.showLoginAlert(context);
                              }
                            },
                            child: Card(
                              // color: Colors.blue,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 3),
                                child: ListTile(
                                  title: Text(eachTopicObj.name),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : Center(
                        child: Text(
                          'No topics available',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} */

/* -------------------------------------------Testing--------------------------------------------------- */

/* import 'package:debate/src/models/topic.dart';
import 'package:debate/src/services/topic_service.dart';
import 'package:debate/src/views/screens/create_topic.dart';
import 'package:debate/src/views/screens/schedule_debate.dart';
import 'package:flutter/material.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Topic> topicsObject = [];
  bool isLoading = true;

  final controller = ScrollController();
  int page = 1;
  int pageSize = 6;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchAllTopics();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetchAllTopics();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

  /* Fetching all topics from DB */
  Future<void> fetchAllTopics() async {
    if (isLoadingMore || !hasMore) return;
    setState(() {
      isLoadingMore = true;
    });
    try {
      final fetchedTopics = await TopicService().fetchTopics(page, pageSize);
      setState(() {
        page++;
        isLoadingMore = false;
        if (fetchedTopics.length < pageSize) {
          hasMore = false;
        }
        // topicsObject = fetchedTopics;
        topicsObject.addAll(fetchedTopics);
        isLoading = false;
      });
    } catch (e) {
      // throw Exception('Topics fetching failed');
      print('Exception in topics page: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        actions: [
          IconButton(
            onPressed: () {
              if (glb.accessToken != "") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTopic(),
                  ),
                );
              } else {
                glb.showLoginAlert(context);
              }
            },
            icon: Icon(
              Icons.add_box_rounded,
              size: 30,
            ),
          )
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              'Select or Create a topic to schedule a debate',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : topicsObject.isNotEmpty
                    ? ListView.builder(
                        controller: controller,
                        itemCount: topicsObject.length + 1,
                        itemBuilder: (context, index) {
                          if (index < topicsObject.length) {
                            final eachTopicObj = topicsObject[index];
                            return InkWell(
                              onTap: () {
                                if (glb.accessToken != "") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ScheduleDebate(
                                              topicName: eachTopicObj.name)));
                                } else {
                                  glb.showLoginAlert(context);
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Card(
                                  // color: Colors.blue,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 35),
                                    child: ListTile(
                                      title: Text(eachTopicObj.name),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: hasMore
                                    ? CircularProgressIndicator()
                                    : Text('No more data'),
                              ),
                            );
                          }
                        },
                      )
                    : Center(
                        child: Text(
                          'No topics available',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} */

/* ---------------------------Pagination correctly working with fetchTopics(boolean initialLoad)------------------------------ */

import 'package:flutter/material.dart';
import 'package:debate/src/models/topic.dart';
import 'package:debate/src/services/topic_service.dart';
import 'package:debate/src/views/screens/create_topic.dart';
import 'package:debate/src/views/screens/schedule_debate.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class TopicsPage extends StatefulWidget {
  const TopicsPage({Key? key}) : super(key: key);

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Topic> topics = []; // List to store fetched topics
  bool isLoading = false; // Flag to indicate if the initial load is in progress
  bool isLoadingPaginatedData =
      false; // Flag to indicate if more topics are being loaded (pagination) or Flag indicates whether the application is currently in the process of fetching more data.
  bool hasMore = true; // Flag to indicate if there are more topics to load
  final int pageSize = 6; // Number of topics to fetch per page
  int page = 1; // Current page number

  final ScrollController controller =
      ScrollController(); // Scroll controller to detect scrolling

  @override
  void initState() {
    super.initState();
    controller
        .addListener(_scrollListener); // Add scroll listener to the controller
    fetchTopics(initialLoad: true, parentId: -1); // Fetch initial data
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

  // Method to handle scrolling and trigger data fetching when the end is reached
  void _scrollListener() {
    if (controller.position.atEdge && controller.position.pixels != 0) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        // fetchTopics(
        // initialLoad: false); // Fetch more data when the bottom is reached
      }
    }
  }

  // Method to fetch data from the API
  Future<void> fetchTopics(
      {required bool initialLoad, required int parentId}) async {
    // Return early if already loading data or no more data to fetch
    if (isLoading || isLoadingPaginatedData || !hasMore) return;

    // Set loading state based on whether it's the initial load or pagination
    if (initialLoad) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoadingPaginatedData = true;
      });
    }

    try {
      // Fetch topics from the TopicService
      final List<Topic> fetchedTopics =
          await TopicService().fetchTopics(page, pageSize, parentId);

      setState(() {
        // If fetched topics are less than pageSize, it indicates no more topics to load
        if (fetchedTopics.length < pageSize) {
          hasMore = false;
        }
        topics.addAll(fetchedTopics); // Add fetched topics to the list
        page++; // Increment the page number for the next fetch
      });
    } catch (e) {
      print('Exception in topics page: $e');
      // Show an error message to the user if the fetch fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load topics'),
        ),
      );
    } finally {
      // Reset loading states
      if (initialLoad) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoadingPaginatedData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        actions: [
          IconButton(
            onPressed: () {
              if (glb.accessToken.isNotEmpty) {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => CreateTopic(),
                //   ),
                // );
              } else {
                glb.showLoginAlert(
                    context); // Show login alert if the user is not logged in
              }
            },
            icon: Icon(
              Icons.add_box_rounded,
              size: 30,
            ),
          )
        ],
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator for initial load
          : topics.isEmpty
              ? Center(
                  child: Text('No topics available'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      child: Text(
                        'Select or Create a topic to schedule a debate',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: topics.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < topics.length) {
                            final topic = topics[index];
                            return InkWell(
                              onTap: () {
                                if (glb.accessToken.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleDebate(
                                        topicName: topic.name,
                                        selectedTopic: '', // need to check
                                      ),
                                    ),
                                  );
                                } else {
                                  glb.showLoginAlert(
                                      context); // Show login alert if the user is not logged in
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 40),
                                    child: ListTile(
                                      title: Text(topic.name),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (isLoadingPaginatedData) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child:
                                    CircularProgressIndicator(), // Show loading indicator for pagination
                              ),
                            );
                          } else {
                            return SizedBox(); // Empty space when there's no more data to load
                          }
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}



/* ------------------------------------------------------------------ */

/* ----------------------------------------With pagination------------------------------------ */

/* import 'package:debate/src/models/topic.dart';
import 'package:debate/src/services/topic_service.dart';
import 'package:flutter/material.dart';

class TopicsPage extends StatefulWidget {
  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Topic> _topics = [];
  bool _loading = false;
  int _page = 1;
  int _pageSize = 8;
  ScrollController _scrollController = ScrollController();
  bool _allTopicsFetched = false;

  @override
  void initState() {
    print('inside initstate');
    super.initState();
    _fetchTopics();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    print('called scroll');
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchTopics();
    }
  }

  Future<void> _fetchTopics() async {
    print('inside async');
    if (!_loading && !_allTopicsFetched) {
      setState(() {
        _loading = true;
      });
      try {
        print('inside try');
        final topics = await TopicService().fetchTopics(_page, _pageSize);
        if (topics.isNotEmpty) {
          setState(() {
            _topics.addAll(topics);
            _loading = false;
            _page++;
          });
        } else {
          // No more topics available, stop pagination
          setState(() {
            _loading = false;
            _allTopicsFetched = true;
          });
        }
      } catch (e) {
        print('inside catch');
        print('exception: $e');
        setState(() {
          _loading = false;
        });
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topic List'),
      ),
      body: _buildTopicList(),
    );
  }

  Widget _buildTopicList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _topics.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        print('inside listview');
        if (index < _topics.length) {
          final eachTopicObj = _topics[index];
          print('inside if');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Card(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                title: Text(eachTopicObj.name),
                // Add more details as needed
              ),
            ),
          );
        } else {
          print('inside else');
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
} */
