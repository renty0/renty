import { Routes } from '@angular/router';
import { BrandListComponent } from './brand-list/brand-list.component';
import { AdminGuard } from '../../core/guards/admin.guard';

export const BrandsRoutes: Routes = [
    {
        path: 'brands',
        component: BrandListComponent,
        canActivate: [AdminGuard]
    }
];
