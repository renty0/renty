import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ExpertAssigned } from './expert-assigned';

describe('ExpertAssigned', () => {
  let component: ExpertAssigned;
  let fixture: ComponentFixture<ExpertAssigned>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExpertAssigned]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ExpertAssigned);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
