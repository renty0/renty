import { Routes } from '@angular/router';
import { ProductListComponent } from './product-list/product-list.component';
import { ProductEditorPageComponent } from './product-editor-page/product-editor-page.component';

export const ProductsRoutes: Routes = [
    {
        path: 'products',
        component: ProductListComponent
    },
    {
        path: 'products/new',
        component: ProductEditorPageComponent
    },
    {
        path: 'products/:id/edit',
        component: ProductEditorPageComponent
    }
];
