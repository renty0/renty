import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-system-settings',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './system-settings.component.html',
  styleUrls: ['./system-settings.component.scss']
})
export class SystemSettingsComponent implements OnInit {
  private http = inject(HttpClient);

  settings = signal<{ [key: string]: string }>({});
  
  // Specific toggles
  commissionRate = signal<number>(15);
  maintenanceMode = signal<boolean>(false);

  isLoading = signal(false);
  isSaving = signal(false);
  successMsg = signal<string | null>(null);

  ngOnInit() {
    this.loadSettings();
  }

  loadSettings() {
    this.isLoading.set(true);
    this.http.get<{ [key: string]: string }>('/api/v1/admin/settings').subscribe({
      next: (res) => {
        this.settings.set(res);
        if (res['PlatformCommission']) {
          this.commissionRate.set(parseFloat(res['PlatformCommission']) * 100);
        }
        if (res['MaintenanceMode']) {
          this.maintenanceMode.set(res['MaintenanceMode'] === 'true');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load settings', err);
        this.isLoading.set(false);
      }
    });
  }

  saveSetting(key: string, value: string, desc: string) {
    this.isSaving.set(true);
    this.successMsg.set(null);
    this.http.post('/api/v1/admin/settings', { key, value, description: desc }).subscribe({
      next: () => {
        this.successMsg.set(`${key} updated successfully.`);
        this.isSaving.set(false);
        this.loadSettings();
      },
      error: () => this.isSaving.set(false)
    });
  }

  updateCommission() {
    this.saveSetting('PlatformCommission', (this.commissionRate() / 100).toString(), 'Global platform commission rate for rentals');
  }

  toggleMaintenance() {
    this.saveSetting('MaintenanceMode', this.maintenanceMode() ? 'true' : 'false', 'Enable/Disable maintenance mode');
  }
}
