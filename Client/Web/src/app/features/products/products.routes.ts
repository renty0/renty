import { Routes } from '@angular/router';
import { ProductListComponent } from './product-list/product-list.component';
import { ProductEditorPageComponent } from './product-editor-page/product-editor-page.component';
import { AdminGuard } from '../../core/guards/admin.guard';
import { AuthGuard } from '../../core/guards/auth.guard';

export const ProductsRoutes: Routes = [
    {
        path: 'products',
        component: ProductListComponent,
        canActivate: [AdminGuard],

    },
    {
        path: 'products/new',
        component: ProductEditorPageComponent,
        canActivate: [AuthGuard],
    },
    {
        path: 'products/:id/edit',
        component: ProductEditorPageComponent,
        canActivate: [AdminGuard],
    }
];
