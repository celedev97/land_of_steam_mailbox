import {Component, EventEmitter, Output, signal} from '@angular/core';
import {FormControl} from "@angular/forms";
import {User, UserService} from "../../services/user.service";
import {map, Observable, startWith} from "rxjs";
import {LanguageService} from "../../services/language.service";

@Component({
  selector: 'app-dialog-destination',
  templateUrl: './dialog-destination.component.html',
  styleUrls: ['./dialog-destination.component.scss']
})
export class DialogDestinationComponent {

  autocompleteDestination = new FormControl<string>('');
  protected filteredUsers: Observable<User[]>;

  @Output() select = new EventEmitter<User>();

  @Output() close = new EventEmitter<void>();

  selectedUser?: User;

  constructor(
    protected lang: LanguageService,
    protected userService: UserService,
  ) {
    this.filteredUsers = this.autocompleteDestination.valueChanges.pipe(
      startWith(''),
      map(value => {
        const validUsers = this.userService.users.filter(user =>
          `${user.firstname} ${user.lastname}`.toLowerCase().includes(value!.toLowerCase())
        );

        if(validUsers.includes(this.selectedUser!)) {
          this.selectedUser = undefined;
        }

        return validUsers;
      }),
    );
  }

  selectDestination() {
    if(this.selectedUser) {
      this.select.emit(this.selectedUser);
      this.close.emit();
    }
  }

  selectUser(user: User) {
    this.selectedUser = user;
    this.autocompleteDestination.setValue(`${user.firstname} ${user.lastname}`, {emitEvent: false});
  }
}
