import { Component } from '@angular/core';
import { LanguageService } from '../services/language.service';
import { Observable, map, startWith } from 'rxjs';
import { FormControl } from '@angular/forms';
import {Letter, TelegramService} from "../services/telegram.service";
import {BackendService} from "../services/backend.service";
import {User, UserService} from "../services/user.service";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  _tab: 'read'|'write'|'broadcast'|undefined = undefined;
  set tab(tab: 'read'|'write'|'broadcast'|undefined) {
    this._tab = tab;
    if(tab == 'read') {
      this.backendService.forceGetMessages().subscribe();
    }
    if(tab == 'write') {
      this.backendService.forceGetUsers().subscribe();
    }
    this.myMessage = '';
    this.destinationUser = undefined;
    this.selectedTelegram = undefined;
    this.showSelectDialog = false;
  }
  get tab() {
    return this._tab;
  }

  showSelectDialog = false;
  selectedTelegram: Letter | undefined = undefined;
  destinationUser?: User;
  myMessage: string = '';

  constructor(
    public lang: LanguageService,
    public telegramService: TelegramService,
    public backendService: BackendService,
    protected userService: UserService,
  ) {
    window.addEventListener('message', (event) => {
      /**
       * @type {{
       *     action: string,
       *     users: string,
       *     messages: string,
       *     language: string
       * }}
       * */
      const message = event.data;


      switch (message.action) {
        case 'open':
          console.log("Received open message");
          this.tab = 'read';
          break;
        case 'open_broadcast':
          console.log("Received open broadcast message");
          this.tab = 'broadcast';
          break;
        case 'close':
          console.log("Received close message");
          this.tab = undefined;
          break;
        default:
          return;
      }

    });

  }

  selectDestination(user: User) {
    this.destinationUser = user;
    this.showSelectDialog = false;
  }

  private setMessages(parse: any) {

  }

  public closeUI() {
    this.backendService.closeUI().subscribe();
  }

  deleteMail(selectedTelegram: Letter) {
    this.backendService.deleteMessage(selectedTelegram.id).subscribe((res) => {})
    setTimeout(() => {
      this.backendService.forceGetMessages().subscribe();
    }, 500);
  }

  markAsRead(selectedTelegram: Letter) {
    selectedTelegram.opened = 1;
    this.backendService.markAsRead(selectedTelegram.id).subscribe((res) => {})
  }

  toLocalDate(received_at: string) {
    var hours = new Date(received_at).getHours();
    var minutes = new Date(received_at).getMinutes();
    return new Date(received_at).toLocaleDateString() + " - " + hours + ":" + minutes;
  }

  select(letter: Letter) {
    this.selectedTelegram = this.selectedTelegram != letter ? letter : undefined;
    if(this.selectedTelegram && this.selectedTelegram.opened == 0) {
      this.markAsRead(this.selectedTelegram);
    }
  }

  sendMessage() {
    console.log("BEFORE SEND", this.destinationUser, this.myMessage);
    if(this.destinationUser && this.myMessage) {
      this.backendService.sendTelegram(this.destinationUser, this.myMessage).subscribe((res) => {
        console.log(res)
      });
      console.log("AFTER SEND", this.destinationUser, this.myMessage);
      this.tab = 'read';
    }
  }

  answerMail(selectedTelegram: Letter) {
    this.tab = 'write';
    this.destinationUser = this.userService.getUser(selectedTelegram.steam);
  }
}
