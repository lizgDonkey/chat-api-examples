import 'package:chat_flutter/http_request_manager.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as convert;
import 'custom_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements EMChatManagerListener {
  final ImagePicker _picker = ImagePicker();
  List<Widget> listItem = [];
  String groupId = "";
  List<String> listStr = [];
  String? _userId, _password, _singleChatId, _msgContent, _groupId;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  void initSDK() async {
    var options = EMOptions(appKey: "41117440#383391");
    await EMClient.getInstance.init(options);

    EMClient.getInstance.chatManager.addChatManagerListener(this);
  }

  @override
  Widget build(BuildContext context) {
    updateItem();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Title(
            color: Colors.blue,
            child: const Text("agora chat api example"),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 2,
              child: ListView.builder(
                itemBuilder: (_, index) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.grey[100],
                    height: 60,
                    child: Center(
                      child: listItem[index],
                    ),
                  );
                },
                itemCount: listItem.length,
              ),
            ),
            Flexible(
              child: TextScrollView(
                controller: _controller,
                textList: listStr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateItem() {
    listItem.clear();
    listItem.add(usernameAndPasswordWidget());
    listItem.add(accountWidget());
    listItem.add(
      InputTextWidget(
        hintText: "single chat Id",
        onChange: (str) {
          _singleChatId = str;
        },
      ),
    );
    listItem.add(
      InputTextWidget(
        maxLines: 5,
        hintText: "message content",
        onChange: (str) {
          _msgContent = str;
        },
      ),
    );
    listItem.add(sendMessageWidget());
    listItem.add(
      InputTextWidget(
        hintText: "group ID",
        onChange: (str) {
          _groupId = str;
        },
      ),
    );
    listItem.add(joinGroupWidget());
  }

  void signUpAction() async {
    if (_userId?.isNotEmpty == true && _password?.isNotEmpty == true) {
      String log = "Sign up failure";
      String? response = await HttpRequestManager.registerToAppServer(
          username: _userId!, password: _password!);
      if (response != null) {
        Map<String, dynamic>? map = convert.jsonDecode(response);
        if (map != null) {
          if (map["code"] == "RES_OK") {
            log = "Sign up success";
          }
        }
      }
      addLogToConsole(log);
    } else {
      addLogToConsole("username or password is null");
    }
  }

  void signInAction() async {
    if (_userId?.isNotEmpty == true && _password?.isNotEmpty == true) {
      String log = "Sign in failure";
      String? response = await HttpRequestManager.loginToAppServer(
          username: _userId!, password: _password!);
      if (response != null) {
        Map<String, dynamic>? map = convert.jsonDecode(response);
        if (map != null) {
          if (map["code"] == "RES_OK") {
            String? accessToken = map["accessToken"];
            String? loginName = map["chatUserName"];
            if (accessToken?.isNotEmpty == true &&
                loginName?.isNotEmpty == true) {
              addLogToConsole("login app server success !");
              try {
                await EMClient.getInstance
                    .loginWithAgoraToken(loginName!, accessToken!);
                log = "login SDK success ! name : $loginName";
              } on EMError catch (e) {
                log = e.toString();
              }
            }
          }
        }
      }
      addLogToConsole(log);
    } else {
      addLogToConsole("username or password is null");
    }
  }

  void signOutAction() async {
    String log = "";
    try {
      await EMClient.getInstance.logout(true);
      log = "logout result : success !";
    } on EMError catch (e) {
      log = "logout result : ${e.description} !";
    } finally {
      addLogToConsole(log);
    }
  }

  void sendText() async {
    String log = "";
    do {
      bool isLoggedIn = await EMClient.getInstance.isLoginBefore();
      if (!isLoggedIn) {
        log = "not login";
        break;
      }

      if (_singleChatId?.isNotEmpty == true) {
      } else {
        log = "conversationId is null !";
        break;
      }

      if (_msgContent?.isNotEmpty == true) {
      } else {
        log = "message content is null !";
        break;
      }

      EMMessage msg = EMMessage.createTxtSendMessage(
        username: _singleChatId!,
        content: _msgContent!,
      );
      msg.setMessageStatusCallBack(MessageStatusCallBack(
        onSuccess: () {
          addLogToConsole(
            "send message success: $_msgContent",
          );
        },
        onError: (e) {
          addLogToConsole(
            "send message fail ! errDesc : ${e.description}",
          );
        },
      ));
      try {
        await EMClient.getInstance.chatManager.sendMessage(msg);
      } on EMError catch (e) {
        log = "send message fail ! errDesc : ${e.description}";
      }
      setState(() {});
    } while (false);
    if (log.isNotEmpty) {
      addLogToConsole(log);
    }
  }

  void sendImage() async {
    String log = "";
    do {
      bool isLoggedIn = await EMClient.getInstance.isLoginBefore();
      if (!isLoggedIn) {
        log = "not login";
        break;
      }

      if (_singleChatId?.isNotEmpty == true) {
      } else {
        log = "conversationId is null !";
        break;
      }

      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 300,
          maxHeight: 300,
          imageQuality: 1,
        );

        EMMessage msg = EMMessage.createImageSendMessage(
            username: _singleChatId!, filePath: pickedFile!.path);

        msg.setMessageStatusCallBack(MessageStatusCallBack(onSuccess: () {
          addLogToConsole(
            "send message success ! messageType : ${_getBodyType(msg)}",
          );
        }, onError: (e) {
          addLogToConsole(
            "send message fail ! errDesc : ${e.description}",
          );
        }, onProgress: (progress) {
          addLogToConsole(
            "progress: $progress ",
          );
        }));
        addLogToConsole(
          "begin send.",
        );

        try {
          await EMClient.getInstance.chatManager.sendMessage(msg);
        } on EMError catch (e) {
          log = "send message fail ! errDesc : ${e.description}";
        }
      } on EMError catch (e) {
        log = e.description;
      } catch (e) {
        log = e.toString();
      }
    } while (false);
    if (log.isNotEmpty) {
      addLogToConsole(
        log,
      );
    }
  }

  void joinGroup() async {
    String log = "";
    do {
      bool isLoggedIn = await EMClient.getInstance.isLoginBefore();
      if (!isLoggedIn) {
        log = "not login";
        break;
      }

      if (_groupId?.isNotEmpty == true) {
        try {
          await EMClient.getInstance.groupManager.joinPublicGroup(_groupId!);
          log = "join group success ! groupID : $_groupId";
          break;
        } on EMError catch (e) {
          log = "join group fail ! errDesc :  ${e.description}";
          break;
        }
      } else {
        log = "group id is null !";
      }
    } while (false);

    addLogToConsole(log);
  }

  Widget usernameAndPasswordWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: InputTextWidget(
            hintText: "user ID",
            onChange: (str) {
              _userId = str;
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: InputTextWidget(
            hintText: "password",
            onChange: (str) {
              _password = str;
            },
          ),
        ),
      ],
    );
  }

  Widget accountWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: Button(title: "Sign in", onPressed: signInAction)),
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Button(title: "Sign up", onPressed: signUpAction)),
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Button(title: "Sign out", onPressed: signOutAction)),
      ],
    );
  }

  Widget sendMessageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: Button(title: "send", onPressed: sendText)),
        const SizedBox(
          width: 10,
        ),
        Expanded(child: Button(title: "send image", onPressed: sendImage)),
      ],
    );
  }

  Widget joinGroupWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: Button(title: "join group", onPressed: joinGroup))
      ],
    );
  }

  void addLogToConsole(String text) {
    listStr.add("$timeString: $text");
    setState(() {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _controller.jumpTo(_controller.position.maxScrollExtent),
      );
    });
  }

  String get timeString {
    return DateTime.now().toString().split(".").first;
  }

  String _getBodyType(EMMessage msg) {
    String ret = "";
    switch (msg.body.type) {
      case MessageType.TXT:
        ret = "";
        break;
      case MessageType.IMAGE:
        ret = "AgoraChatMessageBodyTypeImage";
        break;
      case MessageType.VIDEO:
        ret = "AgoraChatMessageBodyTypeVideo";
        break;
      case MessageType.VOICE:
        ret = "AgoraChatMessageBodyTypeVoice";
        break;
      case MessageType.FILE:
        ret = "AgoraChatMessageBodyTypeFile";
        break;
      case MessageType.LOCATION:
        ret = "AgoraChatMessageBodyTypeLocation";
        break;
      case MessageType.CMD:
        ret = "AgoraChatMessageBodyTypeCmd";
        break;
      case MessageType.CUSTOM:
        ret = "AgoraChatMessageBodyTypeCustom";
        break;
    }
    return ret;
  }

  @override
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  @override
  void onConversationRead(String from, String to) {}

  @override
  void onConversationsUpdate() {}

  @override
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}

  @override
  void onMessagesDelivered(List<EMMessage> messages) {}

  @override
  void onMessagesRead(List<EMMessage> messages) {}

  @override
  void onMessagesRecalled(List<EMMessage> messages) {}

  @override
  void onMessagesReceived(List<EMMessage> messages) {
    for (var item in messages) {
      if (item.body.type == MessageType.TXT) {
        String text = (item.body as EMTextMessageBody).content;
        addLogToConsole(
            "receive a AgoraChatMessageBodyTypeText message : $text, from : ${item.from}");
      } else {
        addLogToConsole(
            "receive a ${_getBodyType(item)} message, from : ${item.from}");
      }
    }
  }
}
