using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Application.Features.Rentals;
using Domain.Entities;
using Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using EntityFrameworkCoreMock;
using Xunit;

namespace Tests;

public class CancelRentalTests
{
    private readonly Mock<IUser> _currentUserMock;
    private readonly Mock<INotificationSender> _notifierMock;
    private readonly Mock<IHttpContextAccessor> _httpContextAccessorMock;
    private readonly Mock<IApplicationDbContext> _contextMock;

    public CancelRentalTests()
    {
        _currentUserMock = new Mock<IUser>();
        _notifierMock = new Mock<INotificationSender>();
        _httpContextAccessorMock = new Mock<IHttpContextAccessor>();
        _contextMock = new Mock<IApplicationDbContext>();
        
        var httpContext = new DefaultHttpContext();
        _httpContextAccessorMock.Setup(x => x.HttpContext).Returns(httpContext);
    }

    [Theory]
    [InlineData(CancellationPolicy.Flexible, 48, 1.0)] // 48h before (Flexible) -> 100% refund
    [InlineData(CancellationPolicy.Flexible, 12, 0.5)] // 12h before (Flexible) -> 50% refund
    [InlineData(CancellationPolicy.Moderate, 6 * 24, 1.0)] // 6 days before (Moderate) -> 100% refund
    [InlineData(CancellationPolicy.Moderate, 2 * 24, 0.5)] // 2 days before (Moderate) -> 50% refund
    [InlineData(CancellationPolicy.Strict, 8 * 24, 0.5)] // 8 days before (Strict) -> 50% refund
    [InlineData(CancellationPolicy.Strict, 2 * 24, 0.0)] // 2 days before (Strict) -> 0% refund
    public async Task Renter_Cancel_Confirmed_Rental_Applies_Policy(CancellationPolicy policy, double hoursBeforeStart, double expectedRefundMultiplier)
    {
        // Arrange
        var ownerId = 1L;
        var renterId = 2L;
        _currentUserMock.Setup(x => x.Id).Returns(renterId);

        var owner = new ApplicationUser { Id = ownerId, PendingBalance = 1000m, WalletBalance = 0m };
        var renter = new ApplicationUser { Id = renterId, PendingBalance = 500m, WalletBalance = 0m }; 
        var users = new List<ApplicationUser> { owner, renter };

        var item = new Item { Id = Guid.NewGuid(), OwnerId = ownerId, CancellationPolicy = policy };
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
            StartDate = DateTime.UtcNow.AddHours(hoursBeforeStart),
            RentalPrice = 1000m,
            DepositAmount = 500m,
            PlatformCommissionPercent = 15m
        };
        var rentals = new List<Rental> { rental };

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            OrderId = orderId,
            Amount = 1500m, // 1000 fee + 500 deposit
            Method = PaymentMethod.Wallet,
            Status = PaymentStatus.Success
        };
        var payments = new List<Payment> { payment };

        var walletTransactions = new List<WalletTransaction>();

        // Mock DbSets using EntityFrameworkCoreMock
        var usersMock = new DbSetMock<ApplicationUser>(users, (x, _) => x.Id);
        var itemsMock = new DbSetMock<Item>(items, (x, _) => x.Id);
        var rentalsMock = new DbSetMock<Rental>(rentals, (x, _) => x.Id);
        var paymentsMock = new DbSetMock<Payment>(payments, (x, _) => x.Id);
        
        var walletTransactionsMock = new DbSetMock<WalletTransaction>(walletTransactions, (x, _) => x.Id);
        walletTransactionsMock.Setup(d => d.Add(It.IsAny<WalletTransaction>())).Callback<WalletTransaction>(walletTransactions.Add);

        _contextMock.Setup(c => c.Users).Returns(usersMock.Object);
        _contextMock.Setup(c => c.Items).Returns(itemsMock.Object);
        _contextMock.Setup(c => c.Rentals).Returns(rentalsMock.Object);
        _contextMock.Setup(c => c.Payments).Returns(paymentsMock.Object);
        _contextMock.Setup(c => c.WalletTransactions).Returns(walletTransactionsMock.Object);

        var handler = new CancelRentalCommandHandler(_contextMock.Object, _currentUserMock.Object, _notifierMock.Object, _httpContextAccessorMock.Object);

        // Act
        var result = await handler.Handle(new CancelRentalCommand(rentalId), CancellationToken.None);

        // Assert
        Assert.True(result.Success);

        var updatedRental = _contextMock.Object.Rentals.First(r => r.Id == rentalId);
        var updatedRenter = _contextMock.Object.Users.First(u => u.Id == renterId);
        var updatedOwner = _contextMock.Object.Users.First(u => u.Id == ownerId);

        Assert.Equal(RentalStatus.Cancelled, updatedRental.Status);

        decimal feeToRetain = Math.Round(1000m * (1.0m - (decimal)expectedRefundMultiplier), 2);
        decimal expectedRenterRefund = 1500m - feeToRetain; 
        Assert.Equal(expectedRenterRefund, updatedRenter.WalletBalance);
        
        Assert.Equal(0m, updatedOwner.PendingBalance);
        Assert.Equal(0m, updatedRenter.PendingBalance);

        if (feeToRetain > 0)
        {
            decimal platformCut = Math.Round(feeToRetain * 0.15m, 2);
            decimal ownerCompensation = feeToRetain - platformCut;
            Assert.Equal(ownerCompensation, updatedOwner.WalletBalance);
            
            // Check transactions exist
            Assert.Contains(walletTransactions, t => t.Type == TransactionType.Penalty && t.Amount == -feeToRetain);
            Assert.Contains(walletTransactions, t => t.Type == TransactionType.RentalEarnings && t.Amount == ownerCompensation);
        }
        else
        {
            Assert.Equal(0m, updatedOwner.WalletBalance);
        }
    }
}
