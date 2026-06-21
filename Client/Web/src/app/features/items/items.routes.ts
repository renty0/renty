import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
import { ItemsEditorPageComponent } from './items-editor-page/items-editor-page.component';
import { ItemsListComponent } from './items-list/items-list.component';
import { ItemDetailPageComponent } from './item-detail-page/item-detail-page.component';
import { VerifiedGuard } from '../../core/guards/verified.guard';

export const ItemsRoutes: Routes = [
  {
    path: 'items/new',
    component: ItemsEditorPageComponent,
    canActivate: [AuthGuard, VerifiedGuard],
  },
  {
    path: 'items/:id/edit',
    component: ItemsEditorPageComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'items/:id',
    component: ItemDetailPageComponent,
  },
  {
    path: 'my-items',
    component: ItemsListComponent,
    canActivate: [AuthGuard],
    data: { ownerMode: 'me' }
  }
];
