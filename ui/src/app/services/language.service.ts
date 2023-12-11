import { Injectable } from '@angular/core';
import {BackendService} from "./backend.service";

const LOCALSTORAGE_KEY = 'mailbox_language';

@Injectable({
  providedIn: 'root'
})
export class LanguageService {
  uiTitleLabel: string = 'US Postal';

  uiCloseButton: string = 'Close';
  uiWriteButton: string = 'Write';
  uiDeleteButton: string = 'Delete';
  uiAnswerButton: string = 'Answer';
  uiAbortButton: string = 'Cancel';
  uiSendButton: string = 'Send';
  uiSelectButton: string = 'Select';

  uiYourMessagePlaceholder: string = 'Your message...';
  uiNoMessages: string = 'No telegrams received';

  uiDestinationLabel: string = 'Destination';
  uiTelegramLabel: string = 'Telegram';
  uiChooseDestinationLabel: string = 'Choose destination';

  uiNamePrefix: string = 'From';

  constructor(
    private backendService: BackendService,
  ) {
    let langFromLocalStorage = window.localStorage.getItem(LOCALSTORAGE_KEY);
    if (langFromLocalStorage) {
      this.setLanguage(JSON.parse(langFromLocalStorage))
    }

    window.addEventListener('message', (event) => {
      const message = event.data;

      if (message.action == 'set_language') {
          this.setLanguage(JSON.parse(message.language))
      }
    });

    backendService.forceGetLanguage().subscribe();
  }
  public setLanguage(languageJSON: {[key:string]:string}) {
      window.localStorage.setItem(LOCALSTORAGE_KEY, JSON.stringify(languageJSON));

      this.uiTitleLabel = languageJSON['UITitleLabel'];

      this.uiCloseButton = languageJSON['UICloseButton'] || this.uiCloseButton;
      this.uiWriteButton = languageJSON['UIWriteButton'] || this.uiWriteButton;
      this.uiDeleteButton = languageJSON['UIDeleteButton'] || this.uiDeleteButton;
      this.uiAnswerButton = languageJSON['UIAnswerButton'] || this.uiAnswerButton;
      this.uiAbortButton = languageJSON['UIAbortButton'] || this.uiAbortButton;
      this.uiSendButton = languageJSON['UISendButton'] || this.uiSendButton;
      this.uiSelectButton = languageJSON['UISelectButton'] || this.uiSelectButton;

      this.uiYourMessagePlaceholder = languageJSON['UIYourMessagePlaceholder'] || this.uiYourMessagePlaceholder;
      this.uiNoMessages = languageJSON['UINoMessages'] || this.uiNoMessages;

      this.uiDestinationLabel = languageJSON['UIDestinationLabel'] || this.uiDestinationLabel;
      this.uiTelegramLabel = languageJSON['UITelegramLabel'] || this.uiTelegramLabel;
      this.uiChooseDestinationLabel = languageJSON['UIChooseDestinationLabel'] || this.uiChooseDestinationLabel;

      this.uiNamePrefix = languageJSON['UINamePrefix'] || this.uiNamePrefix;
  }
}
