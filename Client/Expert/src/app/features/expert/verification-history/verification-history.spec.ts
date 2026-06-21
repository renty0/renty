import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VerificationHistoryComponent } from './verification-history';

describe('VerificationHistoryComponent', () => {
  let component: VerificationHistoryComponent;
  let fixture: ComponentFixture<VerificationHistoryComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VerificationHistoryComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VerificationHistoryComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
