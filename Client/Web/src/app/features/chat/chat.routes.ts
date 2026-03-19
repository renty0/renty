import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const CHAT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    children: [
      {
        path: '',
        loadComponent: () => import('./chat-list/chat-list').then(m => m.ChatListComponent)
      },
      {
        path: ':id',
        loadComponent: () => import('./chat-room/chat-room').then(m => m.ChatRoomComponent)
      }
    ]
  }
];
