using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Reviews;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record ReviewerDto(string FirstName, string? ProfileImageUrl);
public record ReviewDto(Guid Id, int Rating, string? Comment, ReviewerDto Reviewer, DateTime CreatedAt);

// ── CREATE REVIEW ─────────────────────────────────────────────────────────────

public record CreateReviewCommand(Guid RentalId, int Rating, string? Comment) : IRequest<CreateReviewResponse>;
public record CreateReviewResponse(bool Success, string? Error, Guid? ReviewId, int? Rating, string? Comment);

public class CreateReviewCommandValidator : AbstractValidator<CreateReviewCommand>
{
    public CreateReviewCommandValidator()
    {
        RuleFor(x => x.RentalId).NotEmpty();
        RuleFor(x => x.Rating).InclusiveBetween(1, 5).WithMessage("Rating must be between 1 and 5.");
    }
}

public class CreateReviewCommandHandler : IRequestHandler<CreateReviewCommand, CreateReviewResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;

    public CreateReviewCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
    }

    public async Task<CreateReviewResponse> Handle(CreateReviewCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateReviewResponse(false, "Unauthorized.", null, null, null);

        var rental = await _context.Rentals
            .Include(r => r.Item)
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new CreateReviewResponse(false, "Rental not found.", null, null, null);
        
        bool isRenter = rental.UserId == _currentUser.Id.Value;
        bool isOwner = rental.Item.OwnerId == _currentUser.Id.Value;

        if (!isRenter && !isOwner)
            return new CreateReviewResponse(false, "Only the renter or owner can review this rental.", null, null, null);
        if (rental.Status != RentalStatus.Completed)
            return new CreateReviewResponse(false, "Can only review completed rentals.", null, null, null);

        var alreadyReviewed = await _context.Reviews.AnyAsync(r => r.RentalId == request.RentalId && r.ReviewerId == _currentUser.Id.Value, ct);
        if (alreadyReviewed)
            return new CreateReviewResponse(false, "You have already reviewed this rental.", null, null, null);

        var review = new Review
        {
            RentalId = request.RentalId,
            ReviewerId = _currentUser.Id.Value,
            Rating = request.Rating,
            Comment = request.Comment,
            CreatedAt = DateTime.UtcNow
        };
        _context.Reviews.Add(review);

        _context.UserInteractions.Add(new UserInteraction
        {
            UserId = _currentUser.Id.Value,
            ItemId = rental.ItemId,
            Action = InteractionAction.Review,
            CreatedAt = DateTime.UtcNow
        });

        long targetUserId = isRenter ? rental.Item.OwnerId : rental.UserId;
        var targetUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == targetUserId, ct);
        
        if (targetUser != null)
        {
            if (isRenter)
            {
                // Renter is rating the owner
                targetUser.OwnerTotalRatings += 1;
                targetUser.OwnerRating = Math.Round(
                    ((targetUser.OwnerRating * (targetUser.OwnerTotalRatings - 1)) + request.Rating) / targetUser.OwnerTotalRatings, 2);

                // Update combined rating for backward compatibility
                targetUser.TotalRatings += 1;
                targetUser.Rating = Math.Round(
                    ((targetUser.Rating * (targetUser.TotalRatings - 1)) + request.Rating) / targetUser.TotalRatings, 2);
            }
            else
            {
                // Owner is rating the renter
                targetUser.RenterTotalRatings += 1;
                targetUser.RenterRating = Math.Round(
                    ((targetUser.RenterRating * (targetUser.RenterTotalRatings - 1)) + request.Rating) / targetUser.RenterTotalRatings, 2);

                // Update combined rating for backward compatibility
                targetUser.TotalRatings += 1;
                targetUser.Rating = Math.Round(
                    ((targetUser.Rating * (targetUser.TotalRatings - 1)) + request.Rating) / targetUser.TotalRatings, 2);
            }
            
            // Send notification to the target user
            await _notifier.SendToUserAsync(
                targetUserId,
                "New Review Received",
                $"You have received a {request.Rating}-star review for the rental of '{rental.Item.TitleEn}'.",
                "review",
                $"/profile/{targetUserId}",
                ct,
                titleAr: "تم استلام تقييم جديد",
                messageAr: $"لقد تلقيت تقييماً بـ {request.Rating} نجوم لإيجار '{(!string.IsNullOrWhiteSpace(rental.Item.TitleAr) ? rental.Item.TitleAr : rental.Item.TitleEn)}'."
            );
        }

        await _context.SaveChangesAsync(ct);
        return new CreateReviewResponse(true, null, review.Id, review.Rating, review.Comment);
    }
}

// ── GET ITEM REVIEWS ──────────────────────────────────────────────────────────

public record GetItemReviewsQuery(Guid ItemId) : IRequest<GetItemReviewsResponse>;
public record GetItemReviewsResponse(List<ReviewDto> Reviews, double AvgRating, int TotalReviews);

public class GetItemReviewsQueryHandler : IRequestHandler<GetItemReviewsQuery, GetItemReviewsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetItemReviewsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetItemReviewsResponse> Handle(GetItemReviewsQuery request, CancellationToken ct)
    {
        var reviews = await _context.Reviews
            .Include(r => r.Reviewer)
            .Include(r => r.Rental)
            .Where(r => r.Rental.ItemId == request.ItemId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ReviewDto(
                r.Id, r.Rating, r.Comment,
                new ReviewerDto(r.Reviewer.FirstName, r.Reviewer.ProfilePictureUrl),
                r.CreatedAt
            ))
            .ToListAsync(ct);

        var avg = reviews.Count > 0 ? Math.Round(reviews.Average(r => r.Rating), 2) : 0;
        return new GetItemReviewsResponse(reviews, avg, reviews.Count);
    }
}
