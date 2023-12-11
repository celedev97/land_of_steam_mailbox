import { Injectable } from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {User} from "./user.service";

const API = 'http://vorp_los_mailbox';

@Injectable({
  providedIn: 'root'
})
export class BackendService {

  constructor(
    private http: HttpClient
  ) { }

  public closeUI() {
    console.error('closeUI');
    return this.http.post(`${API}/close`, {});
  }

  public sendBroadcastMessage(message: string) {
    return this.http.post(`${API}/broadcast`, {message});
  }

  public sendMessage(message: string, destination: string) {
    return this.http.post(`${API}/broadcast`, {message, destination});
  }

  public forceGetUsers() {
    return this.http.get(`${API}/forceGetUsers`);
  }

  public forceGetMessages() {
    return this.http.get(`${API}/forceGetMessages`);
  }

  public forceGetLanguage() {
    return this.http.get(`${API}/forceGetLanguage`);
  }

  public deleteMessage(id: number) {
    return this.http.post(`${API}/delete`, {id:id});
  }

  public markAsRead(id: number) {
    return this.http.post(`${API}/markAsRead`, {id:id});
  }

  sendTelegram(destinationUser: User, message: string) {
    return this.http.post(`${API}/send`, {
      receiver: destinationUser,
      message: message
    });
  }
}
