import { Directive, inject, Input, OnDestroy, OnInit, TemplateRef, ViewContainerRef } from '@angular/core';
import { AuthService } from '../services/auth.service';

@Directive({
    selector: '[appHasPermission]',
    standalone: true
})
export class HasPermissionDirective implements OnInit, OnDestroy {
    private templateRef = inject(TemplateRef<unknown>);
    private viewContainer = inject(ViewContainerRef);
    private authService = inject(AuthService);

    private permission: any = null;
    private isVisible = false;

    @Input() set appHasPermission(permission: any) {
        this.permission = permission;
        this.updateView();
    }

    ngOnInit(): void {
        this.updateView();
    }

    ngOnDestroy(): void {
        this.viewContainer.clear();
    }

    private updateView(): void {
        const hasAccess = this.checkAccess();

        if (hasAccess && !this.isVisible) {
            this.viewContainer.createEmbeddedView(this.templateRef);
            this.isVisible = true;
        } else if (!hasAccess && this.isVisible) {
            this.viewContainer.clear();
            this.isVisible = false;
        }
    }

    private checkAccess(): boolean {
        if (this.authService.isSuperAdmin()) {
            return true;
        }
        if (!this.permission) {
            return true;
        }
        return this.authService.hasPermission(this.permission);
    }
}
