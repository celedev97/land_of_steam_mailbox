import { Injectable } from '@angular/core';
import {BackendService} from "./backend.service";

const LOCAL_STORAGE_KEY = 'mailbox_users';

export interface User {
  firstname: string;
  lastname: string;
  steam: string;
}

@Injectable({
  providedIn: 'root'
})
export class UserService {

  users: User[] = [];

  constructor(
    backendService: BackendService,
  ) {
    let usersFromLocalStorage = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (usersFromLocalStorage) {
      this.users = JSON.parse(usersFromLocalStorage);
    }

    window.addEventListener('message', (event) => {
      const message = event.data;

      if(message.action == 'set_users') {
        this.setUsers(JSON.parse(message.users));
      }
    });

    backendService.forceGetUsers().subscribe();
  }

  public setUsers(users: User[]) {
    this.users = users;
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(users));
    console.error('setUsers', users)
  }

  getUser(steam: string) {
    return this.users.find(user => user.steam == steam);
  }
}
