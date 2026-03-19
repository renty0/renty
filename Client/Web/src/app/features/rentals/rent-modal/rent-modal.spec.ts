import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RentModal } from './rent-modal';

describe('RentModal', () => {
  let component: RentModal;
  let fixture: ComponentFixture<RentModal>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RentModal]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RentModal);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
