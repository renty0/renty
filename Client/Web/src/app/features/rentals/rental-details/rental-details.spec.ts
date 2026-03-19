import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RentalDetails } from './rental-details';

describe('RentalDetails', () => {
  let component: RentalDetails;
  let fixture: ComponentFixture<RentalDetails>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RentalDetails]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RentalDetails);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
