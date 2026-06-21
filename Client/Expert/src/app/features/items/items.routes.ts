import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
import { ItemsListComponent } from './items-list/items-list.component';
import { ItemDetailPageComponent } from './item-detail-page/item-detail-page.component';

export const ItemsRoutes: Routes = [
  {
    path: 'items',
    component: ItemsListComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'items/:id',
    component: ItemDetailPageComponent,
    canActivate: [AuthGuard]
  }
];
