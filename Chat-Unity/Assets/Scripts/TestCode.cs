using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ChatSDK;
using UnityEngine.UI;
using ChatSDK.MessageBody;

public class TestCode : MonoBehaviour, IChatManagerDelegate
{
    static string APPKEY = "easemob-demo#easeim";

    public InputField Username;
    public InputField Password;
    public InputField SignChatId;
    public InputField MessageContent;
    public InputField GroupId;

    public Button SignInBtn;
    public Button SignUpBtn;
    public Button SignOutBtn;
    public Button SendMsgBtn;
    public Button JoinGroupBtn;


    public Text LogText;


    // Start is called before the first frame update
    void Start()
    {
        SetupUI();
        InitSDK();
        AddChatDelegate();
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void SetupUI()
    {
        SignInBtn.onClick.AddListener(SignInAction);
        SignUpBtn.onClick.AddListener(SignUpAction);
        SignOutBtn.onClick.AddListener(SignOutAction);
        SendMsgBtn.onClick.AddListener(SendMessageAction);
        JoinGroupBtn.onClick.AddListener(JoinGroupAction);
    }

    private void InitSDK()
    {
        var options = new Options(appKey: APPKEY);
        SDKClient.Instance.InitWithOptions(options);
    }

    private void AddChatDelegate() {
        SDKClient.Instance.ChatManager.AddChatManagerDelegate(this);
    }

    private void SignInAction() {
        if (Username.text.Length == 0 || Password.text.Length == 0) {
            AddLogToLogText("username or password is null");
            return;
        }

        SDKClient.Instance.Login(username: Username.text, pwdOrToken: Password.text, handle: new CallBack(
            onSuccess: () => {
                AddLogToLogText("sign in sdk succeed");
            },
            onError:(code, desc) => {
                AddLogToLogText($"sign in sdk failed, code: {code}, desc: {desc}");
            }
        ));
    }

    private void SignUpAction()
    {
        if (Username.text.Length == 0 || Password.text.Length == 0)
        {
            AddLogToLogText("username or password is null");
            return;
        }

        SDKClient.Instance.CreateAccount(username: Username.text, Password.text, handle: new CallBack(
            onSuccess: () => {
                AddLogToLogText("sign up sdk succeed");
            },
            onError: (code, desc) => {
                AddLogToLogText($"sign up sdk failed, code: {code}, desc: {desc}");
            }
        ));
    }

    private void SignOutAction()
    {
        SDKClient.Instance.Logout(true, handle: new CallBack(
            onSuccess: () => {
                AddLogToLogText("sign out sdk succeed");
            },
            onError: (code, desc) => {
                AddLogToLogText($"sign out sdk failed, code: {code}, desc: {desc}");
            }
        ));
    }

    private void SendMessageAction ()
    {
        if (SignChatId.text.Length == 0 || MessageContent.text.Length == 0) {
            AddLogToLogText("Sign chatId or message content is null");
            return;
        }

        Message msg = Message.CreateTextSendMessage(SignChatId.text, MessageContent.text);
        SDKClient.Instance.ChatManager.SendMessage(ref msg, new CallBack(
            onSuccess: () => {
                AddLogToLogText($"send message succeed, receiver: {SignChatId.text},  message: {MessageContent.text}");
            },
            onError:(code, desc) => {
                AddLogToLogText($"send message failed, code: {code}, desc: {desc}");
            }
        ));
    }

    private void JoinGroupAction()
    {
        if (GroupId.text.Length == 0)
        {
            AddLogToLogText("groupId is null, please input group id");
            return;
        }

        SDKClient.Instance.GroupManager.JoinPublicGroup(groupId: GroupId.text, new CallBack(
            onSuccess: () => {
                AddLogToLogText($"join group succeed, groupId: {GroupId.text}");
            },
            onError: (code, desc) => {
                AddLogToLogText($"join group failed, code: {code}, desc: {desc}");
            }
        ));
    }

    private void AddLogToLogText(string str) {
        LogText.text += System.DateTime.Now +": " + str + "\n";
    }

    public void OnMessagesReceived(List<Message> messages)
    {
        foreach (Message msg in messages) {
            if (msg.Body.Type == MessageBodyType.TXT)
            {
                TextBody txtBody = msg.Body as TextBody;
                AddLogToLogText($"received text message: {txtBody.Text}, from: {msg.From}");
            }
            else if (msg.Body.Type == MessageBodyType.IMAGE)
            {
                ImageBody imageBody = msg.Body as ImageBody;
                AddLogToLogText($"received image message, from: {msg.From}");
            }
            else if (msg.Body.Type == MessageBodyType.VIDEO) {
                VideoBody videoBody = msg.Body as VideoBody;
                AddLogToLogText($"received video message, from: {msg.From}");
            }
            else if (msg.Body.Type == MessageBodyType.VOICE)
            {
                VoiceBody voiceBody = msg.Body as VoiceBody;
                AddLogToLogText($"received voice message, from: {msg.From}");
            }
            else if (msg.Body.Type == MessageBodyType.LOCATION)
            {
                LocationBody localBody = msg.Body as LocationBody;
                AddLogToLogText($"received location message, from: {msg.From}");
            }
            else if (msg.Body.Type == MessageBodyType.FILE)
            {
                FileBody fileBody = msg.Body as FileBody;
                AddLogToLogText($"received file message, from: {msg.From}");
            }
        }
    }

    public void OnCmdMessagesReceived(List<Message> messages)
    {
        
    }

    public void OnMessagesRead(List<Message> messages)
    {
        
    }

    public void OnMessagesDelivered(List<Message> messages)
    {
        
    }

    public void OnMessagesRecalled(List<Message> messages)
    {
        
    }

    public void OnReadAckForGroupMessageUpdated()
    {
        
    }

    public void OnGroupMessageRead(List<GroupReadAck> list)
    {
        
    }

    public void OnConversationsUpdate()
    {
        
    }

    public void OnConversationRead(string from, string to)
    {
        
    }
}