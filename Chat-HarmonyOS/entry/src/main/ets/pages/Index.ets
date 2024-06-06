import { ChatClient, ChatOptions, ChatMessage,
  TextMessageBody, ContentType, ChatMessageListener,
  ChatCallback, ChatError } from 'chatsdk';
import { Prompt } from '@kit.ArkUI';
import intl from '@ohos.intl'

@Entry
@Component
struct Index {
  @State logInfo: string = '';
  @State userId: string = '';
  @State pwd: string = '';
  @State to: string = '';
  @State content: string = '';
  scroller: Scroller = new Scroller();

  private initSDK() {
    let options = new ChatOptions();
    options.setAppKey("easemob#easeim");
    options.setAutoLogin(false);
    ChatClient.getInstance().init(options);
  }

  private login(userId: string, pwd: string) {
    ChatClient.getInstance().login(userId, pwd).then(()=> {
      this.registerMessageListener();
      this.addLog("Login success!");
    }).catch((e: ChatError) => {
      this.addLog("Login failed, error: "+e.errorCode);
    })
  }

  private sendMessage(to: string, content: string) {
    let message = ChatMessage.createTextSendMessage(to, content);
    if (!message) {
      this.addLog("message is undefined");
      return;
    }
    let callback: ChatCallback = {
      onSuccess: () => {
        this.addLog("Send message success, message id: "+message?.getMsgId(), false);
        this.scrollToBottom();
      },
      onError: (code: number, error: string) => {
        this.addLog("Send message failed, message id: "+message?.getMsgId() + " errorCode: "+code);
        this.scrollToBottom();
      }
    }
    message.setMessageStatusCallback(callback);
    ChatClient.getInstance().chatManager()?.sendMessage(message);
  }

  private registerMessageListener() {
    let messageListener: ChatMessageListener = {
      onMessageReceived: (messages: ChatMessage[]): void => {
        let content = 'receive message: ';
        messages.forEach(message => {
          content += "\nid: "+message.getMsgId() + " type: "+message.getType();
          if (message.getType() === ContentType.TXT) {
            content += " content: " + ((message.getBody() as TextMessageBody).getContent());
          }
        })
        this.addLog(content, false);
      }
    }
    ChatClient.getInstance().chatManager()?.addMessageListener(messageListener);
  }

  private scrollToBottom() {
    this.scroller.scrollBy(0, 200);
    while (!this.scroller.isAtEnd()) {
      this.scroller.scrollBy(0, 2000);
    }
  }

  private formatData(): string {
    let dateTimeFormat = new intl.DateTimeFormat("zh-CN", {dateStyle: "short", timeStyle: "medium", hourCycle: "h24"});
    return dateTimeFormat.format(new Date());
  }

  private addLog(newLog: string, showToast: boolean = true) {
    if (showToast) {
      Prompt.showToast({message: newLog});
    }
    let preLog = this.logInfo;
    newLog = this.formatData() + "\t\t" + newLog;
    this.logInfo = preLog + "\n" + newLog;
  }

  build() {
    Column() {
      Blank(30)
      Row() {
        Blank('5%')
        TextInput({placeholder:'用户名', text: this.userId})
          .width('40%')
          .onChange((value) => {
            this.userId = value;
          });
        Blank(10)
        TextInput({placeholder:'密码', text: this.pwd})
          .width('40%')
          .type(InputType.Password)
          .onChange((value)=> {
            this.pwd = value;
          });
        Blank('5%')
      }
      Blank(20)
      Button('登 录')
        .fontSize(20)
        .onClick((event: ClickEvent) => {
          this.initSDK();
          if (!this.userId || !this.pwd) {
            this.addLog("用户名或者密码为空");
            return
          }
          this.login(this.userId, this.pwd);
        })
        .width('80%')
      Blank(40)
      TextInput({placeholder:'好友 ID', text: this.to})
        .width('80%')
        .onChange((value)=> {
          this.to = value;
        });
      Blank(20)
      TextInput({placeholder:'消息内容', text: this.content})
        .width('80%')
        .onChange((value)=> {
          this.content = value;
        });
      Blank(20)
      Button('发送消息')
        .fontSize(20)
        .onClick((event: ClickEvent) => {
          if (!ChatClient.getInstance().isSdkInited()) {
            this.addLog("Please login first");
          }
          if (!this.to || !this.content) {
            this.addLog("to or content is empty");
            return
          }
          this.sendMessage(this.to, this.content);
        })
        .width('80%')
      Blank(40)
      Column() {
        Scroll(this.scroller) {
          Text(this.logInfo)
            .fontSize(15)
            .padding({left: 10, right: 10})
            .textAlign(TextAlign.Start)
            .width('100%')
            .layoutWeight(1)
        }
        .width('100%')
        Blank(0)
          .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
  }
}