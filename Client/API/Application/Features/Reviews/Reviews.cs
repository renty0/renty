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

    public CreateReviewCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<CreateReviewResponse> Handle(CreateReviewCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateReviewResponse(false, "Unauthorized.", null, null, null);

        var rental = await _context.Rentals
            .FirstOrDefaultAsync(r => r.Id == request.RentalId, ct);

        if (rental == null) return new CreateReviewResponse(false, "Rental not found.", null, null, null);
        if (rental.UserId != _currentUser.Id.Value)
            return new CreateReviewResponse(false, "Only the renter can review.", null, null, null);
        if (rental.Status != RentalStatus.Completed)
            return new CreateReviewResponse(false, "Can only review completed rentals.", null, null, null);

        var alreadyReviewed = await _context.Reviews.AnyAsync(r => r.RentalId == request.RentalId, ct);
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
