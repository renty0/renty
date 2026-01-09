import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { RegisterCompanyComponent } from '../register-company/register-company.component';
import { RegisterGuardComponent } from '../register-guard/register-guard.component';
import { RegisterFacilityComponent } from '../register-facility/register-facility.component';
import { TranslatePipe } from '@ngx-translate/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [
    RouterModule,
    RegisterCompanyComponent,
    RegisterGuardComponent,
    RegisterFacilityComponent,
    TranslatePipe,
    CommonModule
  ],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent implements OnInit {
  accountType = 'guard';

  ngOnInit(): void {
    const type = localStorage.getItem('accountType');
    if (type) this.accountType = type;
    else this.accountType = 'company';
  }

  changeForm(type: string): void {
    this.accountType = type;
    localStorage.setItem('accountType', type);
  }
}
