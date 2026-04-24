import { Component, inject, signal, OnInit, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { InputComponent } from '../../../shared/components/input/input';
import { AdminSettingsClient, UpdateSettingCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
  selector: 'app-system-settings',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatCardModule,
    MatProgressSpinnerModule,
    TranslateModule,
    HeaderSectionComponent,
    InputComponent
  ],
  templateUrl: './system-settings.component.html',
  styleUrls: ['./system-settings.component.scss']
})
export class SystemSettingsComponent implements OnInit {
  private settingsClient = inject(AdminSettingsClient);
  private toast = inject(ToastService);

  commissionRate = signal<number>(0);
  maintenanceMode = signal<boolean>(false);
  isLoading = signal(true);
  isSaving = signal(false);

  ngOnInit() {
    this.loadSettings();
  }

  loadSettings() {
    this.isLoading.set(true);
    this.settingsClient.getAdminSettings().subscribe({
      next: (res: any) => {
        const settings = res?.data || res;
        if (settings['PlatformCommission']) {
          this.commissionRate.set(Math.round(parseFloat(settings['PlatformCommission']) * 100));
        }
        if (settings['MaintenanceMode']) {
          this.maintenanceMode.set(settings['MaintenanceMode'] === 'true');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.toast.showError('Failed to load system settings');
        this.isLoading.set(false);
      }
    });
  }

  updateCommission() {
    this.saveSetting('PlatformCommission', (this.commissionRate() / 100).toString(), 'Global platform commission rate');
  }

  toggleMaintenance() {
    this.saveSetting('MaintenanceMode', this.maintenanceMode() ? 'true' : 'false', 'Platform maintenance mode toggle');
  }

  private saveSetting(key: string, value: string, description: string) {
    this.isSaving.set(true);
    const cmd = new UpdateSettingCommand({ key, value, description });
    this.settingsClient.updateAdminSetting(cmd).subscribe({
      next: () => {
        this.toast.showSuccess(`${key} updated successfully`);
        this.isSaving.set(false);
        this.loadSettings();
      },
      error: () => {
        this.toast.showError(`Failed to update ${key}`);
        this.isSaving.set(false);
      }
    });
  }
}
