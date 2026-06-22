using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Application.Features.Disputes;
using Domain.Entities;
using Domain.Enums;
using EntityFrameworkCoreMock;
using Moq;
using Xunit;

namespace Tests;

public class DisputeResolutionTests
{
    private readonly Mock<IUser> _currentUserMock;
    private readonly Mock<INotificationSender> _notifierMock;

    public DisputeResolutionTests()
    {
        _currentUserMock = new Mock<IUser>();
        _notifierMock = new Mock<INotificationSender>();
    }

    [Theory]
    [InlineData("refund_renter", 0, 500, 500, DepositStatus.Returned)]
    [InlineData("forfeit_deposit", 500, 0, 500, DepositStatus.Forfeited)]
    [InlineData("split_deposit", 200, 300, 500, DepositStatus.Forfeited)] // Assuming custom split falls into forfeited or returned based on logic, our logic says refund_renter is Returned, else Forfeited.
    public async Task RunDisputeResolutionScenario(string decision, decimal ownerComp, decimal renterRefund, decimal depositAmount, DepositStatus expectedStatus)
    {
        // Arrange
        var ownerId = 1L;
        var renterId = 2L;
        var adminId = 999L;

        var owner = new ApplicationUser { Id = ownerId, WalletBalance = 1000m };
        var renter = new ApplicationUser { Id = renterId, WalletBalance = 500m };
        var users = new List<ApplicationUser> { owner, renter };

        var item = new Item { Id = Guid.NewGuid(), OwnerId = ownerId, TitleEn = "Test Item" };
        var items = new List<Item> { item };

        var rentalId = Guid.NewGuid();
        var rental = new Rental
        {
            Id = rentalId,
            ItemId = item.Id,
            Item = item,
            UserId = renterId,
            DepositAmount = depositAmount,
            DepositStatus = DepositStatus.Held
        };
        var rentals = new List<Rental> { rental };
        var walletTransactions = new List<WalletTransaction>();

        var contextMock = new Mock<IApplicationDbContext>();
        var usersMock = new DbSetMock<ApplicationUser>(users, (x, _) => x.Id);
        var itemsMock = new DbSetMock<Item>(items, (x, _) => x.Id);
        var rentalsMock = new DbSetMock<Rental>(rentals, (x, _) => x.Id);
        var transactionsMock = new DbSetMock<WalletTransaction>(walletTransactions, (x, _) => x.Id);

        transactionsMock.Setup(d => d.Add(It.IsAny<WalletTransaction>())).Callback<WalletTransaction>(walletTransactions.Add);

        contextMock.Setup(c => c.Users).Returns(usersMock.Object);
        contextMock.Setup(c => c.Items).Returns(itemsMock.Object);
        contextMock.Setup(c => c.Rentals).Returns(rentalsMock.Object);
        contextMock.Setup(c => c.WalletTransactions).Returns(transactionsMock.Object);

        // Act
        _currentUserMock.Setup(x => x.Id).Returns(adminId);
        var handler = new ResolveDisputeCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object);
        
        var cmd = new ResolveDisputeCommand(rentalId, decision, ownerComp, renterRefund, "Resolved by unit test");
        var result = await handler.Handle(cmd, CancellationToken.None);

        // Assert
        Assert.True(result.Success, result.Error);
        
        var updatedOwner = contextMock.Object.Users.First(u => u.Id == ownerId);
        var updatedRenter = contextMock.Object.Users.First(u => u.Id == renterId);
        var updatedRental = contextMock.Object.Rentals.First(r => r.Id == rentalId);

        Assert.Equal(1000m + ownerComp, updatedOwner.WalletBalance);
        Assert.Equal(500m + renterRefund, updatedRenter.WalletBalance);
        Assert.Equal(expectedStatus, updatedRental.DepositStatus);

        if (ownerComp > 0)
        {
            Assert.Contains(walletTransactions, t => t.UserId == ownerId && t.Amount == ownerComp && t.Type == TransactionType.Penalty);
        }
        
        if (renterRefund > 0)
        {
            Assert.Contains(walletTransactions, t => t.UserId == renterId && t.Amount == renterRefund && t.Type == TransactionType.Refund);
        }
    }

    [Fact]
    public async Task ResolveDispute_ExceedsDeposit_Fails()
    {
        // Arrange
        var rentalId = Guid.NewGuid();
        var item = new Item { Id = Guid.NewGuid(), OwnerId = 1L, TitleEn = "Test" };
        var rental = new Rental { Id = rentalId, ItemId = item.Id, Item = item, UserId = 2L, DepositAmount = 500m, DepositStatus = DepositStatus.Held };
        var owner = new ApplicationUser { Id = 1L };
        var renter = new ApplicationUser { Id = 2L };

        var contextMock = new Mock<IApplicationDbContext>();
        contextMock.Setup(c => c.Rentals).Returns(new DbSetMock<Rental>(new[] { rental }, (x, _) => x.Id).Object);
        contextMock.Setup(c => c.Users).Returns(new DbSetMock<ApplicationUser>(new[] { owner, renter }, (x, _) => x.Id).Object);

        var handler = new ResolveDisputeCommandHandler(contextMock.Object, _currentUserMock.Object, _notifierMock.Object);
        
        // Act: 300 + 300 = 600 > 500
        var cmd = new ResolveDisputeCommand(rentalId, "split_deposit", 300m, 300m, "Test");
        var result = await handler.Handle(cmd, CancellationToken.None);

        // Assert
        Assert.False(result.Success);
        Assert.Equal("Total payouts cannot exceed the original deposit amount.", result.Error);
    }
}
