import { Routes } from '@angular/router';
import { CategoryListComponent } from './category-list/category-list.component';

export const CategoriesRoutes: Routes = [
    {
        path: 'categories',
        component: CategoryListComponent
    }
];
