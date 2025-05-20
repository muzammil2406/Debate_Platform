import 'package:debate/src/models/user.dart';
import 'package:debate/src/services/debate_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class InviteDebaters extends StatefulWidget {
  final String debateTitle;
  final int debateId;
  const InviteDebaters({
    super.key,
    required this.debateTitle,
    required this.debateId,
  });

  @override
  State<InviteDebaters> createState() => _InviteDebatersState();
}

class _InviteDebatersState extends State<InviteDebaters> {
  final inviteDebaterFormKey = GlobalKey<FormState>();

  /* debater field variables */
  TextEditingController searchDebatersController = TextEditingController();
  List<User> _debaters = [];
  List<User> _selectedDebaters = [];
  List<int> _selectedDebatersId = [];
  ScrollController debaterScrollController = ScrollController();

  /* anchor field variables */
  TextEditingController searchAnchorController = TextEditingController();
  List<User> anchorList = [];
  String selectedAnchor = "";
  List<int> selectedAnchorId = [];
  ScrollController anchorScrollController = ScrollController();

  /* co-anchor field variables */
  TextEditingController searchCoAnchorController = TextEditingController();
  List<User> coAnchorList = [];
  String selectedCoAnchor = "";
  List<int> selectedCoAnchorId = [];
  ScrollController coAnchorScrollController = ScrollController();

  bool isButtonEnabled = false; // initially button is disabled

  /* Button Enable/Disable Logic */
  void updateButtonState() {
    // Enable the button if any text field has a selected user
    isButtonEnabled = _selectedDebatersId.isNotEmpty ||
        (selectedAnchorId.isNotEmpty && selectedAnchor.isNotEmpty) ||
        (selectedCoAnchorId.isNotEmpty && selectedCoAnchor.isNotEmpty);
  }

  /* Fetch users (for debater field) */
  Future<void> _fetchDebaters(String searchTerm) async {
    if (searchTerm.startsWith('@')) {
      try {
        final users = await DebateServices().searchUsers(searchTerm);
        setState(() {
          _debaters = users;
        });
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        _debaters = [];
      });
    }
  }

  /* selecting the users(debaters) from search list */
  void _selectDebaters(User user) {
    setState(() {
      _selectedDebaters.add(user);
      _selectedDebatersId.add(user.id);
      searchDebatersController.clear();
      _debaters.clear();
      updateButtonState(); // update the button state once debater is selected(set to true)
    });
  }

  /* Fetch users (for anchor field) */
  Future<void> fetchAnchor(String searchTerm) async {
    if (searchTerm.startsWith('@')) {
      try {
        final anchors = await DebateServices().searchUsers(searchTerm);
        setState(() {
          anchorList = anchors;
        });
      } catch (e) {
        print('Error in fetchAnchor: $e');
      }
    } else {
      setState(() {
        anchorList = [];
        selectedAnchor = "";
        selectedAnchorId = [];
      });
    }
  }

  /* selecting the users(anchor) from search list */
  void selectAnchor(User user) {
    setState(() {
      selectedAnchor = user.user_name;
      searchAnchorController.text = selectedAnchor;
      anchorList.clear();
      selectedAnchorId.add(user.id);
      updateButtonState(); // update the button state once anchor is selected(set to true)
    });
  }

  /* Fetch users (for co-anchor field) */
  Future<void> fetchCoAnchor(String searchTerm) async {
    if (searchTerm.startsWith('@')) {
      try {
        final coAnchors = await DebateServices().searchUsers(searchTerm);
        setState(() {
          coAnchorList = coAnchors;
        });
      } catch (e) {
        print('Error in fetchCoAnchor: $e');
      }
    } else {
      setState(() {
        coAnchorList = [];
        selectedCoAnchor = "";
        selectedCoAnchorId = [];
      });
    }
  }

  /* selecting the users(co-anchor) from search list */
  void selectCoAnchor(User user) {
    setState(() {
      selectedCoAnchor = user.user_name;
      searchCoAnchorController.text = selectedCoAnchor;
      coAnchorList.clear();
      selectedCoAnchorId.add(user.id);
      updateButtonState(); // update the button state once co-anchor is selected(set to true)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Invite'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.debateTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: searchDebatersController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    _fetchDebaters(value);
                  },
                  decoration: InputDecoration(
                    hintText: '@username',
                    labelText: 'Select debaters',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /* debater stack start */
                Stack(
                  children: [
                    /* debater stack column start */
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _selectedDebaters.map((e) {
                            return Chip(
                              label: Text(e.name),
                              onDeleted: () {
                                setState(() {
                                  _selectedDebaters.remove(e);
                                  _selectedDebatersId.remove(e.id);
                                  /* If a debater chip is deleted, the corresponding user is removed, 
                                  so if _selectedDebaters list is empty then change button state (set to false) */
                                  if (_selectedDebaters.isEmpty) {
                                    updateButtonState();
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        TextField(
                          controller: searchAnchorController,
                          keyboardType: TextInputType.emailAddress,
                          /* If the user clears the text in the anchor TextField, The fetchAnchor function is called, 
                          which will clear the anchorList if the text is empty or does not start with '@'. */
                          /* updateButtonState is called (set to false) */
                          onChanged: (value) {
                            fetchAnchor(value);
                            updateButtonState();
                          },
                          decoration: InputDecoration(
                            hintText: '@username',
                            labelText: 'Select anchor',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        /* anchor stack start */
                        Stack(
                          children: [
                            /* anchor stack column start */
                            Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  controller: searchCoAnchorController,
                                  keyboardType: TextInputType.emailAddress,
                                  /* If the user clears the text in the co-anchor TextField, The fetchCoAnchor function is called, 
                                  which will clear the coAnchorList if the text is empty or does not start with '@'. */
                                  /* updateButtonState is called (set to false) */
                                  onChanged: (value) {
                                    fetchCoAnchor(value);
                                    updateButtonState();
                                  },
                                  decoration: InputDecoration(
                                    hintText: '@username',
                                    labelText: 'Select co-anchor',
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                /* co-anchor stack start */
                                Stack(
                                  children: [
                                    /* co-anchor stack column start */
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size.fromHeight(45),
                                            // shape: RoundedRectangleBorder(
                                            //   borderRadius:
                                            //       BorderRadius.circular(20),
                                            // ),
                                          ),
                                          onPressed: isButtonEnabled
                                              ? () async {
                                                  print(
                                                      'invite button pressed');
                                                  print(
                                                      'selectedDebatersId: $_selectedDebatersId');
                                                  print(
                                                      'selectedDebaters: $_selectedDebaters');
                                                  print(
                                                      'selectedAnchorId: $selectedAnchorId');
                                                  print(
                                                      'selectedAnchor: $selectedAnchor');
                                                  print(
                                                      'selectedCoAnchorId: $selectedCoAnchorId');
                                                  print(
                                                      'selectedCoAnchor: $selectedCoAnchor');
                                                  if (_selectedDebatersId
                                                          .isNotEmpty ||
                                                      selectedAnchorId
                                                          .isNotEmpty ||
                                                      selectedCoAnchorId
                                                          .isNotEmpty) {
                                                    bool inviteStatus =
                                                        await DebateServices()
                                                            .inviteUsers(
                                                      context,
                                                      widget.debateId,
                                                      _selectedDebatersId,
                                                      selectedAnchorId,
                                                      selectedCoAnchorId,
                                                    );
                                                    print(
                                                        'inviteStatus: $inviteStatus');
                                                    if (inviteStatus) {
                                                      glb.showSnackBar(
                                                          context,
                                                          'Participants added successfully and invitation sent',
                                                          Colors.green);

                                                      setState(() {
                                                        _selectedDebaters
                                                            .clear();
                                                        _selectedDebatersId
                                                            .clear();
                                                        selectedAnchorId
                                                            .clear();
                                                        selectedCoAnchorId
                                                            .clear();
                                                        searchAnchorController
                                                            .clear();
                                                        searchCoAnchorController
                                                            .clear();
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                      // Navigator.pushReplacement(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         AllDebatesList(),
                                                      //   ),
                                                      // );
                                                    } else {
                                                      glb.showSnackBar(
                                                          context,
                                                          'Invitation is pending',
                                                          Colors.black);
                                                      setState(() {
                                                        _selectedDebaters
                                                            .clear();
                                                        _selectedDebatersId
                                                            .clear();
                                                        selectedAnchorId
                                                            .clear();
                                                        selectedCoAnchorId
                                                            .clear();
                                                        searchAnchorController
                                                            .clear();
                                                        searchCoAnchorController
                                                            .clear();
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                      });
                                                    }
                                                  } else {
                                                    glb.showSnackBar(
                                                        context,
                                                        "Please select 'Debaters' or 'Anchor' or 'Co-anchor' to invite",
                                                        Colors.red);
                                                  }
                                                }
                                              : null,
                                          child: Text('Invite'),
                                        ),
                                      ],
                                    ),
                                    /* co-anchor stack column end */

                                    /* Displaying list of users based on search text (for co-anchor) */
                                    if (coAnchorList.isNotEmpty)
                                      Positioned(
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxHeight: 200),
                                          child: Card(
                                            elevation: 4,
                                            child: coAnchorList.length > 4
                                                ? Scrollbar(
                                                    controller:
                                                        coAnchorScrollController,
                                                    thumbVisibility: true,
                                                    child: ListView.builder(
                                                        controller:
                                                            coAnchorScrollController,
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            coAnchorList.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return ListTile(
                                                            horizontalTitleGap:
                                                                2,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            leading: coAnchorList[
                                                                            index]
                                                                        .profile_photo_uri !=
                                                                    null
                                                                ? CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            coAnchorList[index].profile_photo_uri!),
                                                                    radius: 16,
                                                                  )
                                                                : FaIcon(
                                                                    FontAwesomeIcons
                                                                        .solidCircleUser,
                                                                    size: 32,
                                                                  ),
                                                            title: Text(
                                                                coAnchorList[
                                                                        index]
                                                                    .name),
                                                            onTap: () {
                                                              selectCoAnchor(
                                                                  coAnchorList[
                                                                      index]);
                                                            },
                                                          );
                                                        }),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        coAnchorList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        horizontalTitleGap: 2,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        leading: coAnchorList[
                                                                        index]
                                                                    .profile_photo_uri !=
                                                                null
                                                            ? CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        coAnchorList[index]
                                                                            .profile_photo_uri!),
                                                                radius: 16,
                                                              )
                                                            : FaIcon(
                                                                FontAwesomeIcons
                                                                    .solidCircleUser,
                                                                size: 32,
                                                              ),
                                                        title: Text(
                                                            coAnchorList[index]
                                                                .name),
                                                        onTap: () {
                                                          selectCoAnchor(
                                                              coAnchorList[
                                                                  index]);
                                                        },
                                                      );
                                                    }),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                /* co-anchor stack end */
                              ],
                            ),
                            /* anchor stack column end */

                            /* Displaying list of users based on search text (for anchor) */
                            if (anchorList.isNotEmpty)
                              Positioned(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 200),
                                  child: Card(
                                    elevation: 4,
                                    child: anchorList.length > 4
                                        ? Scrollbar(
                                            controller: anchorScrollController,
                                            thumbVisibility: true,
                                            child: ListView.builder(
                                                controller:
                                                    anchorScrollController,
                                                shrinkWrap: true,
                                                itemCount: anchorList.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    horizontalTitleGap: 2,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    leading: anchorList[index]
                                                                .profile_photo_uri !=
                                                            null
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    anchorList[
                                                                            index]
                                                                        .profile_photo_uri!),
                                                            radius: 16,
                                                          )
                                                        : FaIcon(
                                                            FontAwesomeIcons
                                                                .solidCircleUser,
                                                            size: 32,
                                                          ),
                                                    title: Text(
                                                        anchorList[index].name),
                                                    onTap: () {
                                                      selectAnchor(
                                                          anchorList[index]);
                                                    },
                                                  );
                                                }),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: anchorList.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                horizontalTitleGap: 2,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                leading: anchorList[index]
                                                            .profile_photo_uri !=
                                                        null
                                                    ? CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(anchorList[
                                                                    index]
                                                                .profile_photo_uri!),
                                                        radius: 16,
                                                      )
                                                    : FaIcon(
                                                        FontAwesomeIcons
                                                            .solidCircleUser,
                                                        size: 32,
                                                      ),
                                                title: Text(
                                                    anchorList[index].name),
                                                onTap: () {
                                                  selectAnchor(
                                                      anchorList[index]);
                                                },
                                              );
                                            }),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        /* anchor stack end */
                      ],
                    ),
                    /* debater stack column end */

                    /* Displaying list of users based on search text (for debaters) */
                    if (_debaters.isNotEmpty)
                      Positioned(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: Card(
                            elevation: 4,
                            child: _debaters.length > 4
                                ? Scrollbar(
                                    controller: debaterScrollController,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                        controller: debaterScrollController,
                                        shrinkWrap: true,
                                        itemCount: _debaters.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            horizontalTitleGap: 2,
                                            visualDensity:
                                                VisualDensity.compact,
                                            leading: _debaters[index]
                                                        .profile_photo_uri !=
                                                    null
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(_debaters[
                                                                index]
                                                            .profile_photo_uri!),
                                                    radius: 16,
                                                  )
                                                : FaIcon(
                                                    FontAwesomeIcons
                                                        .solidCircleUser,
                                                    size: 32,
                                                  ),
                                            title: Text(_debaters[index].name),
                                            onTap: () {
                                              _selectDebaters(_debaters[index]);
                                            },
                                          );
                                        }),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _debaters.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        horizontalTitleGap: 2,
                                        visualDensity: VisualDensity.compact,
                                        leading: _debaters[index]
                                                    .profile_photo_uri !=
                                                null
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    _debaters[index]
                                                        .profile_photo_uri!),
                                                radius: 16,
                                              )
                                            : FaIcon(
                                                FontAwesomeIcons
                                                    .solidCircleUser,
                                                size: 32,
                                              ),
                                        title: Text(_debaters[index].name),
                                        onTap: () {
                                          _selectDebaters(_debaters[index]);
                                        },
                                      );
                                    }),
                          ),
                        ),
                      )
                  ],
                ),
                /* Debater stack end */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
