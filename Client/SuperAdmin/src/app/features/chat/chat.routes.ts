import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const CHAT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    loadComponent: () => import('./chat-layout/chat-layout').then(m => m.ChatLayoutComponent),
    children: [
      {
        path: ':id',
        loadComponent: () => import('./chat-room/chat-room').then(m => m.ChatRoomComponent)
      }
    ]
  }
];
