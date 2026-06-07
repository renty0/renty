import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ExpertAssignedComponent } from './expert-assigned';

describe('ExpertAssignedComponent', () => {
  let component: ExpertAssignedComponent;
  let fixture: ComponentFixture<ExpertAssignedComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExpertAssignedComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ExpertAssignedComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
