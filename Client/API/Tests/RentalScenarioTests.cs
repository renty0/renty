using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Application.Features.Rentals;
using Application.Features.Verifications;
using Domain.Entities;
using Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using EntityFrameworkCoreMock;
using Xunit;
using Infrastructure.Data;

namespace Tests;

public class RentalScenarioTests
{
    private readonly Mock<IUser> _currentUserMock;
    private readonly Mock<INotificationSender> _notifierMock;
    private readonly Mock<IHttpContextAccessor> _httpContextAccessorMock;

    public RentalScenarioTests()
    {
        _currentUserMock = new Mock<IUser>();
        _notifierMock = new Mock<INotificationSender>();
        _httpContextAccessorMock = new Mock<IHttpContextAccessor>();
        
        var httpContext = new DefaultHttpContext();
        _httpContextAccessorMock.Setup(x => x.HttpContext).Returns(httpContext);
    }

    [Theory]
    // Cancelled Before Verification (Renter Cancels)
    [InlineData(false, false, "CancelledBeforeVerification")]
    [InlineData(true, false, "CancelledBeforeVerification")]
    [InlineData(false, true, "CancelledBeforeVerification")]
    [InlineData(true, true, "CancelledBeforeVerification")]
    // Rejected At Verification (Expert Rejects)
    [InlineData(true, false, "RejectedAtVerification")]
    [InlineData(false, true, "RejectedAtVerification")]
    [InlineData(true, true, "RejectedAtVerification")]
    // Completed Normally
    [InlineData(false, false, "CompletedSuccess")]
    [InlineData(true, false, "CompletedSuccess")]
    [InlineData(false, true, "CompletedSuccess")]
    [InlineData(true, true, "CompletedSuccess")]
    public async Task RunLifecycleScenario(bool renterWantsExpert, bool ownerWantsExpert, string phase)
    {
        // 1. Initial State Setup
        var ownerId = 1L;
        var renterId = 2L;
        var expertId = 3L;

        decimal rentalPrice = 1000m;
        decimal depositAmount = 500m;

        decimal renterExpertFeeShare = renterWantsExpert ? (ownerWantsExpert ? 50m : 100m) : 0m;
        decimal ownerExpertFeeShare = ownerWantsExpert ? (renterWantsExpert ? 50m : 100m) : 0m;
        decimal totalExpertFee = renterExpertFeeShare + ownerExpertFeeShare;

        // At Confirmation: 
        // Owner Pending = RentalPrice + ownerExpertFeeShare
        // Renter Pending = DepositAmount + renterExpertFeeShare
        var owner = new ApplicationUser { Id = ownerId, PendingBalance = rentalPrice + ownerExpertFeeShare, WalletBalance = 0m };
        var renter = new ApplicationUser { Id = renterId, PendingBalance = depositAmount + renterExpertFeeShare, WalletBalance = 0m };
        var expert = new ApplicationUser { Id = expertId, PendingBalance = 0m, WalletBalance = 0m };
        var users = new List<ApplicationUser> { owner, renter, expert };

        var item = new Item { Id = Guid.NewGuid(), OwnerId = ownerId, CancellationPolicy = CancellationPolicy.Flexible };
        var items = new List<Item> { item };

        var rentalId = Guid.NewGuid();
        var orderId = Guid.NewGuid();
        var rental = new Rental
        {
            Id = rentalId,
            ItemId = item.Id,
            Item = item,
            UserId = renterId,
            Status = RentalStatus.Confirmed,
            OrderId = orderId,
            StartDate = DateTime.UtcNow.AddDays(2),
            EndDate = DateTime.UtcNow.AddDays(4),
            RentalPrice = rentalPrice,
            DepositAmount = depositAmount,
            PlatformCommissionPercent = 15m,
            RenterWantsExpertReview = renterWantsExpert,
            OwnerWantsExpertReview = ownerWantsExpert,
            ExpertReviewFee = totalExpertFee,
            IsExpertPaid = false,
            CurrentPossession = ItemPossession.Owner,
            DepositStatus = DepositStatus.Held,
            Images = new List<RentalImage> { new RentalImage { Type = RentalImageType.Return } }
        };
        var rentals = new List<Rental> { rental };

        var payment = new Payment { Id = Guid.NewGuid(), OrderId = orderId, Amount = rentalPrice + depositAmount + renterExpertFeeShare, Method = PaymentMethod.Wallet, Status = PaymentStatus.Success };
        var payments = new List<Payment> { payment };
        
        var verifications = new List<ItemVerification>();
        if (totalExpertFee > 0)
        {
            verifications.Add(new ItemVerification
            {
                Id = Guid.NewGuid(),
                RentalId = rentalId,
                ItemId = item.Id,
                ExpertId = expertId,
                CheckType = VerificationCheck.BeforeRent,
                Status = VerificationStatus.Pending
            });
        }

        var walletTransactions = new List<WalletTransaction>();

        // DbSets Mock
        var contextMock = new Mock<IApplicationDbContext>();
        var usersMock = new DbSetMock<ApplicationUser>(users, (x, _) => x.Id);
        var itemsMock = new DbSetMock<Item>(items, (x, _) => x.Id);
        var rentalsMock = new DbSetMock<Rental>(rentals, (x, _) => x.Id);
        var paymentsMock = new DbSetMock<Payment>(payments, (x, _) => x.Id);
        var verificationsMock = new DbSetMock<ItemVerification>(verifications, (x, _) => x.Id);
        var transactionsMock = new DbSetMock<WalletTransaction>(walletTransactions, (x, _) => x.Id);
        
        transactionsMock.Setup(d => d.Add(It.IsAny<WalletTransaction>())).Callback<WalletTransaction>(walletTransactions.Add);

        var favoritesMock = new DbSetMock<Favorite>(new List<Favorite>(), (x, _) => x.Id);
        var itemRemindersMock = new DbSetMock<ItemReminder>(new List<ItemReminder>(), (x, _) => x.Id);

        contextMock.Setup(c => c.Users).Returns(usersMock.Object);
        contextMock.Setup(c => c.Items).Returns(itemsMock.Object);
        contextMock.Setup(c => c.Rentals).Returns(rentalsMock.Object);
        contextMock.Setup(c => c.Payments).Returns(paymentsMock.Object);
        contextMock.Setup(c => c.ItemVerifications).Returns(verificationsMock.Object);
        contextMock.Setup(c => c.WalletTransactions).Returns(transactionsMock.Object);
        contextMock.Setup(c => c.Favorites).Returns(favoritesMock.Object);
        contextMock.Setup(c => c.ItemReminders).Returns(itemRemindersMock.Object);

        // Run Phases
        if (phase == "CancelledBeforeVerification")
        {
            _currentUserMock.Setup(x => x.Id).Returns(renterId);
            var handler = new CancelRentalCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object, _httpContextAccessorMock.Object);
            var result = await handler.Handle(new CancelRentalCommand(rentalId), CancellationToken.None);

            Assert.True(result.Success, result.Error);

            var updatedOwner = contextMock.Object.Users.First(u => u.Id == ownerId);
            var updatedRenter = contextMock.Object.Users.First(u => u.Id == renterId);

            // Assert Escrow Release
            Assert.Equal(0m, updatedOwner.PendingBalance);
            Assert.Equal(0m, updatedRenter.PendingBalance);
            Assert.Equal(ownerExpertFeeShare, updatedOwner.WalletBalance); // Owner gets their expert fee back
            Assert.Equal(rentalPrice + depositAmount + renterExpertFeeShare, updatedRenter.WalletBalance); // Full refund for Flexible > 24h
        }
        else if (phase == "RejectedAtVerification")
        {
            var verification = verifications.First();
            _currentUserMock.Setup(x => x.Id).Returns(expertId);
            var handler = new CreateVerificationCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object);
            await handler.Handle(new CreateVerificationCommand(item.Id, rentalId, "before_rent", "rejected", null, null, null, null), CancellationToken.None);

            var updatedOwner = contextMock.Object.Users.First(u => u.Id == ownerId);
            var updatedRenter = contextMock.Object.Users.First(u => u.Id == renterId);
            var updatedExpert = contextMock.Object.Users.First(u => u.Id == expertId);
            var updatedRental = contextMock.Object.Rentals.First(r => r.Id == rentalId);

            Assert.True(updatedRental.IsExpertPaid);
            Assert.Equal(totalExpertFee, updatedExpert.WalletBalance); // Expert was paid
            
            // Pending balances should have had expert fee deducted
            Assert.Equal(rentalPrice, updatedOwner.PendingBalance);
            Assert.Equal(depositAmount, updatedRenter.PendingBalance);

            // Now cancel the rental because of rejection
            _currentUserMock.Setup(x => x.Id).Returns(renterId); // Renter cancels it
            var cancelHandler = new CancelRentalCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object, _httpContextAccessorMock.Object);
            var cancelResult = await cancelHandler.Handle(new CancelRentalCommand(rentalId), CancellationToken.None);
            Assert.True(cancelResult.Success, cancelResult.Error);

            var finalOwner = contextMock.Object.Users.First(u => u.Id == ownerId);
            var finalRenter = contextMock.Object.Users.First(u => u.Id == renterId);

            Assert.Equal(0m, finalOwner.PendingBalance);
            Assert.Equal(0m, finalRenter.PendingBalance);
            // Since it's cancelled >24h before, renter gets full refund of Rental + Deposit.
            // But NO expert fee is refunded because it was already paid!
            Assert.Equal(rentalPrice + depositAmount, finalRenter.WalletBalance);
            Assert.Equal(0m, finalOwner.WalletBalance);
        }
        else if (phase == "CompletedSuccess")
        {
            if (totalExpertFee > 0)
            {
                var verification = verifications.First();
                _currentUserMock.Setup(x => x.Id).Returns(expertId);
                var handler = new CreateVerificationCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object);
                await handler.Handle(new CreateVerificationCommand(item.Id, rentalId, "before_rent", "approved", null, null, null, null), CancellationToken.None);

                var updatedExpert = contextMock.Object.Users.First(u => u.Id == expertId);
                var updatedRentalForCheck = contextMock.Object.Rentals.First(r => r.Id == rentalId);

                Assert.True(updatedRentalForCheck.IsExpertPaid);
                Assert.Equal(totalExpertFee, updatedExpert.WalletBalance); // Expert was paid
            }

            // Fast forward time to simulate active rental
            var activeRental = contextMock.Object.Rentals.First(r => r.Id == rentalId);
            activeRental.Status = RentalStatus.Active;
            activeRental.EndDate = DateTime.UtcNow.AddDays(1);
            
            _currentUserMock.Setup(x => x.Id).Returns(ownerId);
            var completeHandler = new CompleteRentalCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object);
            var completeResult = await completeHandler.Handle(new CompleteRentalCommand(rentalId, false), CancellationToken.None);
            Assert.True(completeResult.Success, completeResult.Error);

            var finalOwner = contextMock.Object.Users.First(u => u.Id == ownerId);
            var finalRenter = contextMock.Object.Users.First(u => u.Id == renterId);

            Assert.Equal(0m, finalOwner.PendingBalance);
            Assert.Equal(0m, finalRenter.PendingBalance);

            decimal expectedPlatformCommission = rentalPrice * 0.15m;
            decimal expectedOwnerPayout = rentalPrice - expectedPlatformCommission;

            Assert.Equal(expectedOwnerPayout, finalOwner.WalletBalance);
            Assert.Equal(depositAmount, finalRenter.WalletBalance); // Renter gets deposit back
            
            if (totalExpertFee == 0)
            {
                var finalRental = contextMock.Object.Rentals.First(r => r.Id == rentalId);
                var finalExpert = contextMock.Object.Users.First(u => u.Id == expertId);
                Assert.False(finalRental.IsExpertPaid);
                Assert.Equal(0m, finalExpert.WalletBalance);
            }
        }
    }
}
