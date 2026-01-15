import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../../core/services/auth.service';
import { AdminDashboardComponent } from '../admin-dashboard/admin-dashboard.component';
import { OwnerDashboardComponent } from '../owner-dashboard/owner-dashboard.component';
import { RenterDashboardComponent } from '../renter-dashboard/renter-dashboard.component';

@Component({
  selector: 'app-dashboard',
  imports: [CommonModule, AdminDashboardComponent, OwnerDashboardComponent, RenterDashboardComponent],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  private readonly authService = inject(AuthService);

  isAdmin = signal(false);
  isOwner = signal(false);
  isRenter = signal(false);

  ngOnInit() {
    const roles = this.authService.roles();
    this.isAdmin.set(roles.includes('Admin') || roles.includes('SuperAdmin'));
    this.isOwner.set(roles.includes('Owner'));
    this.isRenter.set(roles.includes('Renter'));
  }
}
