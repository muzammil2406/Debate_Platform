/* ---------------------correctly working homepage(topic, sub-topic display)---------------------------- */
import 'dart:io';
import 'package:debate/src/models/topic.dart';
import 'package:debate/src/services/topic_service.dart';
import 'package:debate/src/views/screens/changepassword_page.dart';
import 'package:debate/src/views/screens/create_topic.dart';
import 'package:debate/src/views/screens/editprofile_page.dart';
import 'package:debate/src/views/screens/all_debates_list.dart';
import 'package:debate/src/views/screens/livedebate_page.dart';
import 'package:debate/src/views/screens/notification_page.dart';
import 'package:debate/src/views/screens/notification_services.dart';
import 'package:debate/src/views/screens/schedule_debate.dart';
import 'package:debate/src/views/screens/signin.dart';
import 'package:debate/src/views/screens/topics_page.dart';
import 'package:debate/src/views/screens/video_list_page.dart';
import 'package:flutter/material.dart';
import 'package:debate/src/views/utils/global.dart' as glb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'ads_display.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  NotificationServices notificationServices = NotificationServices();

  List<Topic> topicsObject = [];
  List<String> topicsName = [];
  File? _image;
  bool isEditing = false;
  bool isProfilePhotoSet = false;
  int _currentIndex = 0;

  List<int> selectedTopicIdStack = [-1]; // Stack to keep track of parent IDs
  // Stack to keep track of parent topic name
  List<String> selectedTopicNameStack = ['All'];
  int selectedTopicId = -1;

  int selectedTopicParentId = -1;
  List<int> selectedTopicParentIdStack = [-1];

  int page = 1; // Current page number
  final int pageSize = 50; // Number of topics to fetch per page

  @override
  void initState() {
    super.initState();
    fetchAllTopics(parentId: -1);
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    print('picked image::::::::::::::::::::: $pickedImage');
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        print('image::::: $_image');
      });
      if (_image != null) {
        if (glb.profile_photo_uri.isEmpty) {
          await _uploadImageToServer(_image!);
        } else if (_image != null) {
          _putImageToServer(_image!);
        }
        ;
      }
    }
  }

  Future<void> _getImageFromCamera() async {
    print('In camara async');
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      if (_image != null) {
        if (glb.profile_photo_uri.isEmpty) {
          await _uploadImageToServer(_image!);
        } else if (_image != null) {
          _putImageToServer(_image!);
        }
      }
    }
  }

  Future<void> _uploadImageToServer(File imageFile) async {
    print('image file::::::::::::::::::::::: ${imageFile}');
    print('ENTRY in uploadImageToServer');
    final uri = Uri.parse(glb.backend + '/photo');
    print(' post method uri name= $uri');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${glb.accessToken}';
    request.files.add(await http.MultipartFile.fromPath('pic', imageFile.path));
    var response = await request.send();
    print('post method status Code is : ${response.statusCode}');
    try {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      var photoId = jsonResponse['photo_id'];
      var picture = glb.backend + '/photo/$photoId';
      print('picture is : $picture');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Image uploaded successfully');
        setState(() {
          glb.profile_photo_uri = picture;
        });
      } else {
        print('Failed to upload image. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future _deleteImageFromCache() async {
    print('ENtry in _deleteImageFromCache() ');
    await CachedNetworkImage.evictFromCache(glb.profile_photo_uri);
    setState(() {
      glb.profile_photo_uri;
    });
  }

  Future<void> _putImageToServer(File imageFile) async {
    print('ENTRY in _putImageToServer');
    try {
      Uri url = Uri.parse(glb.profile_photo_uri);

      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer ${glb.accessToken}';

      var image = await http.MultipartFile.fromPath('pic', imageFile.path);
      request.files.add(image);
      var response = await request.send();
      print('put method status code is ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Image update successfully');
        setState(() {
          _deleteImageFromCache();
        });
        print('put image url is : ${glb.profile_photo_uri}');
        await clearImageCache(glb.profile_photo_uri);
        fetchImage();
      } else {
        print('Image upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> clearImageCache(String imageUrl) async {
    print('ENtry in Clear Image cash');
    final uniqueUrl = '$imageUrl?${DateTime.now().millisecondsSinceEpoch}';
    await CachedNetworkImage.evictFromCache(uniqueUrl);
    print('Cache cleared for : $uniqueUrl');
  }

  Future<void> fetchImage() async {
    print('Entry in fetchImage method');
    final response = await http.get(
      Uri.parse(glb.profile_photo_uri),
    );
    print('fetchmethod response status code ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Image showed Success in drawer');
      setState(() {
        glb.profile_photo_uri;
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> deleteProfilePhoto() async {
    print('Entry in deleteProfilePhoto async');
    try {
      if (glb.profile_photo_uri.isNotEmpty) {
        final response = await http.delete(
          Uri.parse(glb.profile_photo_uri),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + glb.accessToken,
          },
        );
        print('deleteProfilePhoto status code is : ${response.statusCode}');
        if (response.statusCode == 204) {
          print('Profile photo deleted successfully');
          setState(() {
            glb.profile_photo_uri = "";
            isProfilePhotoSet = false;
          });
        } else {
          print(
              'Failed to delete profile photo. Status code: ${response.statusCode}');
        }
      } else {
        print('No profile photo to delete');
      }
    } catch (e) {
      print('Error deleting profile photo: $e');
    }
  }

/* -----------------------------fetching all topics----------------------------- */
  Future<void> fetchAllTopics({required int parentId}) async {
    print('parentId: $parentId');
    try {
      final fetchedTopics =
          await TopicService().fetchTopics(page, pageSize, parentId);
      setState(() {
        topicsObject = fetchedTopics; // Add fetched topics to the list
        /* If parentId = -1, initially add 'All', else add 'selectedTopic name' to topicsName list */
        if (parentId == -1) {
          topicsName = ['All'];
        } else {
          topicsName = [selectedTopic];
        }

        topicsName.addAll(topicsObject.map((t) => t.name).toList());
        print('topic names: $topicsName');
      });
    } catch (e) {
      if (e is SocketException) {
        if (e.osError?.errorCode == 101) {
          glb.showSnackBar(context, 'No internet connection', Colors.red);
        } else if (e.osError?.errorCode == 111) {
          glb.showSnackBar(context, 'Server is down', Colors.red);
        }
      } else {
        print('Error in homepage: $e');
      }
    }
  }

  String selectedTopic = "All";

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return VideoListPage(topicName: selectedTopic);
      case 1:
        return livedebate();
      case 2:
        return AllDebatesList(
          topic_id: selectedTopicId,
          topicName: selectedTopic,
          selectedTopicParentId: selectedTopicParentId,
        );
      // case 3:
      //   return AllDebatesMyList();
      // case 4:
      //   return AllDebatesOtherList();
      default:
        return VideoListPage(topicName: selectedTopic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MUDDA'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              print('notification');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationPage(
                          notifications: notificationServices.notifications)));
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: selectedTopicIdStack.length > 1 ? false : true,
        onPopInvoked: (didPop) async {
          if (selectedTopicIdStack.length > 1) {
            selectedTopicIdStack.removeLast(); // Remove the current parent ID
            selectedTopicNameStack
                .removeLast(); // Remove the current parent name
            selectedTopicParentIdStack.removeLast();
            print('selectedTopicIdStack after remove: $selectedTopicIdStack');
            print(
                'selectedTopicNameStack after remove: $selectedTopicNameStack');

            // Get the last parent ID
            int presentTopicId = selectedTopicIdStack.last;
            // Get the last parent name
            String presentTopicName = selectedTopicNameStack.last;
            print('presentTopicId: $presentTopicId');
            print('presentTopicName: $presentTopicName');

            int presentselectedTopicParentId = selectedTopicParentIdStack.last;
            print(
                'presentselectedTopicParentId: $presentselectedTopicParentId');

            // Fetch topics for the previous parent ID
            await fetchAllTopics(parentId: presentTopicId);

            setState(() {
              selectedTopic = presentTopicName;
              selectedTopicId = presentTopicId;
              // replace the current value at index 0 with the value of presentTopicName
              topicsName[0] = presentTopicName;
              selectedTopicParentId = presentselectedTopicParentId;
            });
          }
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 6, top: 8, bottom: 8),
              height: 40,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topicsName.length,
                itemBuilder: ((context, index) {
                  final topic = topicsName[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(
                        topic,
                        style: TextStyle(fontSize: 15),
                      ),
                      onSelected: (bool value) {
                        setState(() {
                          selectedTopic = topic;

                          print('selected topic: $selectedTopic');

                          /* If selected topic's index is greater than 0, then fetch sub-topics of that topic */
                          if (index > 0) {
                            print('inside if');
                            selectedTopicId = topicsObject[index - 1].id;
                            print('Selected topicId: $selectedTopicId');

                            selectedTopicParentId =
                                topicsObject[index - 1].fetchedParentId;

                            print('fetched PID: $selectedTopicParentId');
                            selectedTopicParentIdStack
                                .add(selectedTopicParentId);

                            if (selectedTopicParentId == -1)
                              glb.current_head_topic = selectedTopic;

                            /* Add selected topic's id and name to selectedTopicIdStack and  selectedTopicNameStack respectively */
                            selectedTopicIdStack
                                .add(topicsObject[index - 1].id);
                            selectedTopicNameStack
                                .add(topicsObject[index - 1].name);
                            fetchAllTopics(
                                parentId: topicsObject[index - 1].id);
                            print(
                                'parent id to fetchAllTopics async: ${topicsObject[index - 1].id}');
                            print(
                                'selectedTopicIdStack in if: $selectedTopicIdStack');
                            print(
                                'selectedTopicNameStack in if: $selectedTopicNameStack');
                          }
                          // else {
                          //   print('inside else');
                          //   selectedTopicIdStack.add(-1);
                          //   selectedTopicNameStack.add('All');
                          //   fetchAllTopics(parentId: -1);
                          //   print('selectedTopicIdStack in else: $selectedTopicIdStack');
                          // }
                        });
                      },
                      backgroundColor: Colors.grey.shade300,
                      selectedColor: Colors.grey.shade500,
                      selected: selectedTopic == topic,
                      padding: const EdgeInsets.all(10),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: _getPage(_currentIndex),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(
              Icons.home,
            ),
          ),

          BottomNavigationBarItem(
            label: 'Live Debates',
            icon: Icon(Icons.live_tv),
          ),

          BottomNavigationBarItem(
            label: 'Scheduled Debates',
            icon: Icon(Icons.schedule),
          ),

          // BottomNavigationBarItem(
          //   label: 'My Debate',
          //   icon: Icon(Icons.my_library_books),
          // ),

          // BottomNavigationBarItem(
          //   label: 'Other Debate',
          //   icon: Icon(Icons.other_houses),
          // ),
        ],
        onTap: (int index) {
          setState(() {
            if (index == 0) {
              selectedTopicIdStack = [-1];
              selectedTopicNameStack = ['All'];
              selectedTopicId = -1;
              selectedTopicParentIdStack = [-1];
              selectedTopic = "All";
              fetchAllTopics(parentId: -1);
            }
            _currentIndex = index;
          });
        },
      ),

/*       floatingActionButton: selectedTopic != 'All'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "create_topic_btn",
                  elevation: 0,
                  child: Icon(Icons.create),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateTopic(
                                  selectedTopicId: selectedTopicId,
                                )));
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  heroTag: "schedule_debate_btn",
                  elevation: 0,
                  child: Icon(Icons.schedule),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleDebate(
                          topicName: selectedTopic,
                          selectedTopic: selectedTopic,
                        ),
                      ),
                    );
                  },
                )
              ],
            )
          : null, */

      floatingActionButton: selectedTopic != 'All'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 40,
                  width: 95,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTopic(
                            selectedTopicId: selectedTopicId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create),
                        SizedBox(width: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sub',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Topic',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 40,
                  width: 110,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleDebate(
                            topicName: selectedTopic,
                            selectedTopic: selectedTopic,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Debate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Schedule',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : null,

//======================== Drawer ========================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            InkWell(
              onLongPress: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Choose an option"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Gallery"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _getImageFromGallery();
                          },
                        ),
                        TextButton(
                          child: Text("Camera"),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _getImageFromCamera();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: UserAccountsDrawerHeader(
                accountName: glb.username != ""
                    ? Text('${glb.username}')
                    : Text('Guest User'),
                accountEmail: glb.email != ""
                    ? Text('${glb.email}')
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          visualDensity:
                              VisualDensity(vertical: -1, horizontal: 1),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignIn(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                currentAccountPicture: ClipOval(
                  child: InkWell(
                    onTap: () {
                      if (glb.profile_photo_uri.isNotEmpty) {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 20, bottom: 20),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height: 450,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Image.network(
                                          '${glb.profile_photo_uri}',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Remove Profile Photo?"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text("Yes"),
                                                          onPressed: () async {
                                                            await deleteProfilePhoto();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text("No"),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.blue,
                                                size: 25,
                                              ),
                                            ),
                                            SizedBox(width: 30),
                                            InkWell(
                                              onTap: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Choose an option"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              Text("Gallery"),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await _getImageFromGallery();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text("Camera"),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await _getImageFromCamera();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // If the profile photo URI is empty, show larger version of the default image
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Image.asset(
                                "assets/image/person.png",
                                width: 200,
                                height: 200,
                              ),
                            );
                          },
                        );
                      }
                    },
                    //======================================================================================================
                    child: CachedNetworkImage(
                      imageUrl: glb.profile_photo_uri.isNotEmpty
                          ? '${glb.profile_photo_uri}'
                          : "assets/image/person.png",
                      key: UniqueKey(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/image/person.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            if (glb.accessToken != "")
              ListTile(
                leading: Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => editprofile()));
                },
              ),
            ListTile(
              leading: Icon(Icons.ad_units_sharp),
              title: const Text('Ads Details'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ads_Display()));
              },
            ),
            if (glb.accessToken != "")
              ListTile(
                leading: Icon(Icons.password),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => changepassword()));
                },
              ),
            // ListTile(
            //   leading: Icon(Icons.schedule),
            //   title: const Text('Scheduled Debate'),
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => AllDebatesList()));
            //   },
            // ),
            if (glb.accessToken != "")
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () {
                  glb.conferm_popup(context, 'Are you sure want to Log-out');
                },
              ),
          ],
        ),
      ),
    );
  }
}
