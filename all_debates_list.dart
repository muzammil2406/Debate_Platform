/* ------------------------------------------Displaying all the debates------------------------------------------ */
import 'package:debate/src/models/debate.dart';
import 'package:debate/src/models/meeting_data.dart';
import 'package:debate/src/services/debate_services.dart';
import 'package:debate/src/services/meeting_service.dart';
import 'package:debate/src/views/screens/invite_debaters.dart';
import 'package:debate/src/views/screens/meeting_page.dart';
import 'package:debate/src/views/screens/banner_page.dart';
// import 'package:debate/src/views/screens/thumbnail_page.dart';
import 'package:debate/src/views/screens/update_debate.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class AllDebatesList extends StatefulWidget {
  final int topic_id;
  final String topicName;
  final int selectedTopicParentId;

  const AllDebatesList({
    super.key,
    required this.topic_id,
    required this.topicName,
    required this.selectedTopicParentId,
  });

  @override
  State<AllDebatesList> createState() => _AllDebatesListState();
}

class _AllDebatesListState extends State<AllDebatesList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Debate> debateObjects = [];
  List<Debate> debateTopicwiseObjects = [];
  bool isLoading = true;
  // String meetingId = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchAllDebates(widget.topic_id);
    // fetchTopicwiseDebates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void didUpdateWidget(AllDebatesList oldWidget) {
    print('didUpdateWidget called');
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic_id != widget.topic_id) {
      fetchAllDebates(widget.topic_id);
    }
  }

/* Fetching all debates */
  Future<void> fetchAllDebates(int topic_id) async {
    try {
      List<Debate> fetchedDebates;
      if (topic_id == -1) {
        fetchedDebates = await DebateServices().fetchScheduledDebates();
      } else {
        fetchedDebates = await DebateServices().fetchtopicwiseDebates(topic_id);
      }
      setState(() {
        debateObjects = fetchedDebates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('fetchAllDebates failed: $e');
    }
  }

  /* Future<bool> deleteDebate(int topicId, int debateId) async {
    try {
      await DebateServices().deleteDebate(topicId, debateId);
      return true;
    } catch (e) {
      print('deleteDebate failed: $e');
      return false;
    }
  } */

  DateTime currentDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // print('selectedTopicParentId in all debates list: ${widget.selectedTopicParentId}');
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TabBar(
            controller: _tabController,
            labelColor: Colors.blue, // Color for the selected tab
            unselectedLabelColor: const Color.fromARGB(
                255, 146, 195, 235), // Color for the unselected tabs

            tabs: [
              Tab(text: 'My Debates'),
              Tab(text: 'Other Debates'),
            ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebatesList(isMyDebate: true),
          _buildDebatesList(isMyDebate: false),
        ],
      ),
    );
  }

  Widget _buildDebatesList({required bool isMyDebate}) {
    List<Debate> filteredDebates = debateObjects.where((debate) {
      bool isCreatedByLoggedInUser = debate.allDebatersDetails.any((debater) =>
          debater.userName == glb.username && debater.role.contains('host'));
      return isMyDebate ? isCreatedByLoggedInUser : !isCreatedByLoggedInUser;
    }).toList();

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ((isMyDebate == true && filteredDebates.isNotEmpty) ||
                (isMyDebate == false && filteredDebates.isNotEmpty))
            ? ListView.builder(
                itemCount: filteredDebates.length,
                itemBuilder: (context, index) {
                  final eachDebateObj = filteredDebates[index];

                  /* Converting from epoch format to DateTime format */
                  DateTime scheduledDate = DateTime.fromMillisecondsSinceEpoch(
                      eachDebateObj.scheduledTime);
                  /* Formating DateTime into readable format */
                  String formattedScheduleDT =
                      DateFormat('dd-MM-yyyy, h:mm a').format(scheduledDate);
                  // print(formattedScheduleDT);
                  String fStartDate =
                      DateFormat('dd-MM-yyyy').format(scheduledDate);
                  // print('fStartDate: ${fStartDate}');
                  String fStartTime =
                      DateFormat('h:mm a').format(scheduledDate);
                  // print(fStartTime);
                  /* Converting from epoch format to DateTime format */
                  DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
                      eachDebateObj.endTime);
                  /* Formating DateTime into readable format */
                  String formattedEndDT =
                      DateFormat('dd-MM-yyyy, h:mm a').format(endDate);
                  String fEndDate = DateFormat('dd-MM-yyyy').format(endDate);
                  String fEndTime = DateFormat('h:mm a').format(endDate);

                  /* Check if the logged-in user is the creator of the debate (the creator will have role as, 'host') */
                  final isDebateCreator = eachDebateObj.allDebatersDetails.any(
                    (eachDebater) =>
                        eachDebater.userName == glb.username &&
                        eachDebater.role.contains('host'),
                  );

                  return Column(
                    children: [
                      Card(
                        color: Colors.grey.shade100,
                        elevation: 3,
                        child: ExpansionTile(
                          childrenPadding: EdgeInsets.symmetric(horizontal: 18),
                          title: Text('${eachDebateObj.debateTitle}'),
                          children: [
                            Card(
                              elevation: 6,
                              margin: EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                'Date & Time:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$fStartDate, $fStartTime  to',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    '$fEndDate, $fEndTime',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((isDebateCreator) &&
                                            ((scheduledDate.subtract(
                                                    Duration(minutes: 30)))
                                                .isAfter(currentDateTime)))
                                          PopupMenuButton(
                                            color: Colors.grey.shade100,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            onSelected: (value) {
                                              print('pop up value: $value');
                                              if (value == '/edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateDebate(
                                                      topicId:
                                                          eachDebateObj.topicId,
                                                      debateId: eachDebateObj
                                                          .debateId,
                                                    ),
                                                  ),
                                                );
                                              } else if (value == '/delete') {
                                                /* showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Alert'),
                                                    content: Text(
                                                        'Are you sure you want to delete this debate?'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          // bool isDebateDeleted =
                                                          //     await deleteDebate(
                                                          //         eachDebateObj.topicId,
                                                          //         eachDebateObj
                                                          //             .debateId);
                                                          // if (isDebateDeleted) {
                                                          //   Navigator.of(context).pop();
                                                          //   glb.showSnackBar(
                                                          //       context,
                                                          //       'Debate deleted successfully',
                                                          //       Colors.green);
                                                          //   fetchAllDebates();
                                                          // } else {
                                                          //   Navigator.of(context).pop();
                                                          //   glb.showSnackBar(
                                                          //       context,
                                                          //       'Error occured',
                                                          //       Colors.red);
                                                          // }
                                                        },
                                                        child: Text('Yes'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('No'),
                                                      ),
                                                    ],
                                                  );
                                                }); */
                                              }
                                            },
                                            position: PopupMenuPosition.under,
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry>[
                                              PopupMenuItem(
                                                child: Text('Edit'),
                                                value: '/edit',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Delete'),
                                                value: '/delete',
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'Venue:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        eachDebateObj.venue,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),

                                    eachDebateObj.allDebatersDetails!.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Debaters:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              ...eachDebateObj
                                                  .allDebatersDetails!
                                                  .map((e) {
                                                return ListTile(
                                                  horizontalTitleGap: 0,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  leading: e.imageUri != null
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  e.imageUri!),
                                                          radius: 13,
                                                        )
                                                      : FaIcon(FontAwesomeIcons
                                                          .solidCircleUser),
                                                  title: Row(
                                                    children: [
                                                      e.role.contains('host')
                                                          ? Text(
                                                              '${e.name} (${e.role})')
                                                          : Text(e.name),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (isDebateCreator &&
                                                          !e.role
                                                              .contains('host'))
                                                        IconButton(
                                                          onPressed: () {
                                                            debugPrint(
                                                                'Delete button pressed');
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Alert'),
                                                                  content: Text(
                                                                      'Are you sure you want to delete debater?'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        print(
                                                                            'debateId: ${eachDebateObj.debateId}, userId: ${e.id}');
                                                                        bool isDebaterDeleted = await DebateServices().deleteDebater(
                                                                            eachDebateObj.debateId,
                                                                            e.id);
                                                                        if (isDebaterDeleted) {
                                                                          glb.showSnackBar(
                                                                              context,
                                                                              'Debater deleted successfully',
                                                                              Colors.green);
                                                                          // fetchAllDebates();
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'Yes'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          'No'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 24,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  subtitle:
                                                      Text('State: ${e.state}'),
                                                  trailing: isDebateCreator
                                                      ? e.state == 'Accepted'
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : e.state ==
                                                                  'ACCEPTED'
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : e.state ==
                                                                      'APPROVED'
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .green,
                                                                    )
                                                                  : e.state ==
                                                                          'INVITATION_REQ_SENT'
                                                                      ? FaIcon(
                                                                          FontAwesomeIcons
                                                                              .circleArrowUp,
                                                                          color:
                                                                              Colors.orange,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      : e.state ==
                                                                              'APPROVE_REQ_SENT'
                                                                          ? FaIcon(
                                                                              FontAwesomeIcons.circleArrowDown,
                                                                              color: Colors.amber,
                                                                              size: 20,
                                                                            )
                                                                          : e.state == 'REJECTED'
                                                                              ? Icon(
                                                                                  Icons.cancel,
                                                                                  color: Colors.red,
                                                                                )
                                                                              : Icon(
                                                                                  Icons.pending,
                                                                                )
                                                      : null,
                                                );
                                              }).toList(),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  'Debaters:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Text(
                                                  'No debaters',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                    // if (eachDebateObj.anchorDetails != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'Anchor:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    /* If anchor is present then show anchor or else show msg as, 'No anchor' */
                                    eachDebateObj.anchorDetails != null
                                        ? ListTile(
                                            horizontalTitleGap: 0,
                                            visualDensity:
                                                VisualDensity.compact,
                                            leading: eachDebateObj
                                                        .anchorDetails!
                                                        .imageUri !=
                                                    null
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            eachDebateObj
                                                                .anchorDetails!
                                                                .imageUri!),
                                                    radius: 13,
                                                  )
                                                : FaIcon(FontAwesomeIcons
                                                    .solidCircleUser),
                                            title: Text(eachDebateObj
                                                .anchorDetails!.name),
                                            subtitle: Text(
                                                'State: ${eachDebateObj.anchorDetails!.state}'),
                                            trailing: isDebateCreator
                                                ? eachDebateObj.anchorDetails!
                                                            .state ==
                                                        'ACCEPTED'
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                      )
                                                    : eachDebateObj
                                                                .anchorDetails!
                                                                .state ==
                                                            'INVITATION_REQ_SENT'
                                                        ? FaIcon(
                                                            FontAwesomeIcons
                                                                .circleArrowUp,
                                                            color:
                                                                Colors.orange,
                                                            size: 20,
                                                          )
                                                        : eachDebateObj
                                                                    .anchorDetails!
                                                                    .state ==
                                                                'REJECTED'
                                                            ? Icon(
                                                                Icons.cancel,
                                                                color:
                                                                    Colors.red,
                                                              )
                                                            : Icon(
                                                                Icons.pending)
                                                : null)
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              'No Anchor',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),

                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'Co-Anchor:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    /* If co-anchor is present, show co-anchor or else show msg as, 'No co-anchor' */
                                    eachDebateObj.coAnchorDetails != null
                                        ? ListTile(
                                            horizontalTitleGap: 0,
                                            visualDensity:
                                                VisualDensity.compact,
                                            leading: eachDebateObj
                                                        .coAnchorDetails!
                                                        .imageUri !=
                                                    null
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            eachDebateObj
                                                                .coAnchorDetails!
                                                                .imageUri!),
                                                    radius: 13,
                                                  )
                                                : FaIcon(FontAwesomeIcons
                                                    .solidCircleUser),
                                            title: Text(eachDebateObj
                                                .coAnchorDetails!.name),
                                            subtitle: Text(
                                                'State: ${eachDebateObj.coAnchorDetails!.state}'),
                                            trailing: isDebateCreator
                                                ? eachDebateObj.coAnchorDetails!
                                                            .state ==
                                                        'ACCEPTED'
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                      )
                                                    : eachDebateObj
                                                                .coAnchorDetails!
                                                                .state ==
                                                            'INVITATION_REQ_SENT'
                                                        ? FaIcon(
                                                            FontAwesomeIcons
                                                                .circleArrowUp,
                                                            color:
                                                                Colors.orange,
                                                            size: 20,
                                                          )
                                                        : eachDebateObj
                                                                    .coAnchorDetails!
                                                                    .state ==
                                                                'REJECTED'
                                                            ? Icon(
                                                                Icons.cancel,
                                                                color:
                                                                    Colors.red,
                                                              )
                                                            : Icon(
                                                                Icons.pending)
                                                : null,
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              'No Co-anchor',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                    Text('vc_id: ${eachDebateObj.vcId}'),

                                    /* Show either 'Invite' or 'Send Join Request' button based on isDebateCreator value */
                                    if (isDebateCreator)
                                      /* Invite button */
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        Size.fromHeight(40),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            InviteDebaters(
                                                          debateTitle:
                                                              eachDebateObj
                                                                  .debateTitle,
                                                          debateId:
                                                              eachDebateObj
                                                                  .debateId,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text('Invite'),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        Size.fromHeight(40),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  /* ----------calling api directly---------- */
                                                  onPressed: () async {
                                                    try {
                                                      MeetingData
                                                          startMeetingData =
                                                          await MeetingService()
                                                              .startDebate(
                                                                  eachDebateObj
                                                                      .debateId);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              meetingroom(
                                                            vcId:
                                                                startMeetingData
                                                                    .vcId,
                                                            jwt:
                                                                startMeetingData
                                                                    .jwt,
                                                            appId:
                                                                startMeetingData
                                                                    .appId,
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      print('Exception: $e');
                                                    }
                                                  },
                                                  child: Text('Start Debate'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          if (widget.topicName != 'All')
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      Size.fromHeight(40),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  print(
                                                      'Create Thumbnail Button');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BannerPage(
                                                        topic: widget.topicName,
                                                        debateTitle:
                                                            '${eachDebateObj.debateTitle}',
                                                        //  image: '${eachDebateObj.allDebatersDetails}',
                                                        date: '${fStartDate}',
                                                        allDebatersDetails:
                                                            eachDebateObj
                                                                .allDebatersDetails,
                                                        debateId: eachDebateObj
                                                            .debateId,
                                                        topicId:
                                                            widget.topic_id,
                                                        selectedTopicParentId:
                                                            widget
                                                                .selectedTopicParentId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child:
                                                    Text('Create Thumbnail')),
                                        ],
                                      )
                                    else
                                      /* Send Join Request button */
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize:
                                                    Size.fromHeight(40),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: () async {
                                                print('join button pressed');
                                                bool joinRequestStatus =
                                                    await DebateServices()
                                                        .sendJoinRequest(
                                                            context,
                                                            eachDebateObj
                                                                .debateId,
                                                            glb.userId);
                                                print(joinRequestStatus);
                                                if (joinRequestStatus) {
                                                  glb.showSnackBar(
                                                      context,
                                                      'Join request sent successfully',
                                                      Colors.green);
                                                } else {
                                                  glb.showSnackBar(
                                                      context,
                                                      'Request sending failed',
                                                      Colors.red);
                                                }
                                              },
                                              child: Text('Send Join Request'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize:
                                                    Size.fromHeight(40),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: eachDebateObj
                                                          .debateOn ==
                                                      true
                                                  ? () async {
                                                      try {
                                                        MeetingData
                                                            joinMeetingData =
                                                            await MeetingService()
                                                                .joinDebate(
                                                                    eachDebateObj
                                                                        .debateId);

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    meetingroom(
                                                              vcId:
                                                                  joinMeetingData
                                                                      .vcId,
                                                              jwt:
                                                                  joinMeetingData
                                                                      .jwt,
                                                              appId:
                                                                  joinMeetingData
                                                                      .appId,
                                                            ),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        print('Exception: $e');
                                                      }
                                                    }
                                                  : null,
                                              child: Text('Join Debate'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            : (isMyDebate == true)
                ? Center(
                    child: Text(
                      'You have not created any debates yet',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'No debates yet',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
  }
}
