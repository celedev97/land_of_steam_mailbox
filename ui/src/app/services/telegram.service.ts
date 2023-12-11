import { Injectable } from '@angular/core';
import {BackendService} from "./backend.service";

const LOCALSTORAGE_KEY = 'mailbox_letters';

export interface Letter {
  id: number;
  firstname: string;
  lastname: string;
  steam: string;
  received_at: string;
  message: string;
  opened: 0 | 1;
}

@Injectable({
  providedIn: 'root'
})
export class TelegramService {

  letters: Letter[] = [];


  constructor(
    backendService: BackendService,
  ) {
    let lettersFromLocalStorage = window.localStorage.getItem(LOCALSTORAGE_KEY);
    if (lettersFromLocalStorage) {
      this.letters = JSON.parse(lettersFromLocalStorage)
    }
    window.addEventListener('message', (event) => {
      const message = event.data;

      if(message.action == 'set_messages') {
        this.setMessages(JSON.parse(message.messages));
      }
    });

    backendService.forceGetMessages().subscribe();
  }

  private setMessages(messages: Letter[]) {
    messages = messages.sort((a, b) => {
      return b.id - a.id;
    });
    this.letters = messages;
    window.localStorage.setItem('mailbox_letters', JSON.stringify(messages));
  }

}
