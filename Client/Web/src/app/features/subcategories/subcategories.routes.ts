import { Routes } from '@angular/router';
import { SubcategoryListComponent } from './subcategory-list/subcategory-list.component';
import { AdminGuard } from '../../core/guards/admin.guard';

export const SubcategoriesRoutes: Routes = [
    {
        path: 'subcategories',
        component: SubcategoryListComponent,
        canActivate: [AdminGuard],
    }
];
