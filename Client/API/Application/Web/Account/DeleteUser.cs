using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Domain.Enums;
using System.Linq;

namespace Application.Web.Account;

public record DeleteUserCommand : IRequest<DeleteUserResponse>;

public record DeleteUserResponse(
    bool Success,
    string? Message
);

public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, DeleteUserResponse>
{
    private readonly IUser _currentUser;
    private readonly IIdentityService _identityService;
    private readonly IApplicationDbContext _context;

    public DeleteUserCommandHandler(IUser currentUser, IIdentityService identityService, IApplicationDbContext context)
    {
        _currentUser = currentUser;
        _identityService = identityService;
        _context = context;
    }

    public async Task<DeleteUserResponse> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new DeleteUserResponse(false, "User not authenticated.");
        }

        var userId = _currentUser.Id.Value;
        var user = await _identityService.GetUserByIdAsync(userId);
        if (user == null)
        {
            return new DeleteUserResponse(false, "User not found.");
        }

        // 1. Check for ongoing/active rentals (either as renter or owner of the item)
        var ongoingRentalsExist = await _context.Rentals
            .AnyAsync(r => (r.UserId == userId || r.Item.OwnerId == userId) &&
                           (r.Status == RentalStatus.Pending ||
                            r.Status == RentalStatus.Confirmed ||
                            r.Status == RentalStatus.Active ||
                            r.Status == RentalStatus.Overdue), cancellationToken);

        if (ongoingRentalsExist)
        {
            return new DeleteUserResponse(false, "You cannot delete your account because you have ongoing or pending rentals. Please complete or cancel them first.");
        }

        // 2. Check if the user has past transaction history (past rentals or owned items)
        var hasHistory = await _context.Rentals.AnyAsync(r => r.UserId == userId || r.Item.OwnerId == userId, cancellationToken) ||
                         await _context.Items.AnyAsync(i => i.OwnerId == userId, cancellationToken);

        if (hasHistory)
        {
            // Perform soft-delete/anonymization to satisfy relational integrity and transaction auditing
            user.IsActive = false;
            user.FirstName = "Deleted";
            user.LastName = "User";
            user.Email = $"deleted_user_{userId}@rently.com";
            user.NormalizedEmail = $"DELETED_USER_{userId}@RENTLY.COM".ToUpper();
            user.UserName = $"deleted_user_{userId}";
            user.NormalizedUserName = $"DELETED_USER_{userId}".ToUpper();
            user.ProfilePictureUrl = null;
            user.PhoneNumber = null;
            user.Address = null;
            user.City = null;
            user.Country = null;
            user.Bio = null;

            var updateResult = await _identityService.UpdateUserAsync(user);
            if (!updateResult.Succeeded)
            {
                return new DeleteUserResponse(false, string.Join(", ", updateResult.Errors));
            }

            return new DeleteUserResponse(true, "Your profile has been successfully closed and personal details removed.");
        }

        // 3. No past history: Perform clean hard-delete
        var deleteResult = await _identityService.DeleteUserAsync(user);
        if (!deleteResult.Succeeded)
        {
            return new DeleteUserResponse(false, string.Join(", ", deleteResult.Errors));
        }

        return new DeleteUserResponse(true, "Account deleted successfully.");
    }
}
