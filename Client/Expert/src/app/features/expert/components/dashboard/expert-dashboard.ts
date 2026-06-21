import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-expert-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6 text-center">
      <h1 class="text-3xl font-bold">Expert Dashboard</h1>
      <p class="mt-4">Welcome to the Expert Portal. Pending verifications and disputes will appear here.</p>
    </div>
  `
})
export class ExpertDashboardComponent {}
