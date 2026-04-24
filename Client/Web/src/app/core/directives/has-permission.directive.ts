import { Directive, effect, inject, Input, OnDestroy, OnInit, TemplateRef, ViewContainerRef } from '@angular/core';
import { PermissionService } from '../services/permission.service';

@Directive({
    selector: '[appHasPermission]',
    standalone: true
})
export class HasPermissionDirective implements OnInit, OnDestroy {
    private templateRef = inject(TemplateRef<unknown>);
    private viewContainer = inject(ViewContainerRef);
    private permissionService = inject(PermissionService);

    private permission: string | string[] | null = null;
    private isVisible = false;

    constructor() {
        effect(() => {
            // Trigger update when permissions signal changes
            this.permissionService.permissions();
            this.updateView();
        });
    }

    @Input() set appHasPermission(permission: string | string[] | null) {
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
        if (!this.permission) return true;
        
        if (Array.isArray(this.permission)) {
            return this.permissionService.hasAnyPermission(this.permission);
        }
        
        return this.permissionService.hasPermission(this.permission);
    }
}
