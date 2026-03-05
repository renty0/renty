using Application.Common.Interfaces;
using Application.Features.Items;
using Domain.Entities;
using Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Favorites;

// ── DTOs ─────────────────────────────────────────────────────────────────────

public record FavoriteItemDto(
    Guid Id,
    string Title,
    decimal? DailyPrice,
    string? PrimaryImage,
    string? City
);

// ── ADD FAVORITE ─────────────────────────────────────────────────────────────

public record AddFavoriteCommand(Guid ItemId) : IRequest<AddFavoriteResponse>;
public record AddFavoriteResponse(bool Success, string? Error);

public class AddFavoriteCommandHandler : IRequestHandler<AddFavoriteCommand, AddFavoriteResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public AddFavoriteCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<AddFavoriteResponse> Handle(AddFavoriteCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new AddFavoriteResponse(false, "Unauthorized.");

        var exists = await _context.Favorites
            .AnyAsync(f => f.UserId == _currentUser.Id.Value && f.ItemId == request.ItemId, ct);

        if (exists)
            return new AddFavoriteResponse(false, "Already in favorites.");

        _context.Favorites.Add(new Favorite
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            CreatedAt = DateTime.UtcNow
        });

        _context.UserInteractions.Add(new UserInteraction
        {
            UserId = _currentUser.Id.Value,
            ItemId = request.ItemId,
            Action = InteractionAction.Favorite,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);
        return new AddFavoriteResponse(true, null);
    }
}

// ── REMOVE FAVORITE ───────────────────────────────────────────────────────────

public record RemoveFavoriteCommand(Guid ItemId) : IRequest<RemoveFavoriteResponse>;
public record RemoveFavoriteResponse(bool Success, string? Error);

public class RemoveFavoriteCommandHandler : IRequestHandler<RemoveFavoriteCommand, RemoveFavoriteResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public RemoveFavoriteCommandHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<RemoveFavoriteResponse> Handle(RemoveFavoriteCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new RemoveFavoriteResponse(false, "Unauthorized.");

        var fav = await _context.Favorites
            .FirstOrDefaultAsync(f => f.UserId == _currentUser.Id.Value && f.ItemId == request.ItemId, ct);

        if (fav == null)
            return new RemoveFavoriteResponse(false, "Not found in favorites.");

        _context.Favorites.Remove(fav);
        await _context.SaveChangesAsync(ct);
        return new RemoveFavoriteResponse(true, null);
    }
}

// ── GET MY FAVORITES ──────────────────────────────────────────────────────────

public record GetMyFavoritesQuery : IRequest<GetMyFavoritesResponse>;
public record GetMyFavoritesResponse(bool Success, List<FavoriteItemDto>? Items, string? Error);

public class GetMyFavoritesQueryHandler : IRequestHandler<GetMyFavoritesQuery, GetMyFavoritesResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetMyFavoritesQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetMyFavoritesResponse> Handle(GetMyFavoritesQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new GetMyFavoritesResponse(false, null, "Unauthorized.");

        var items = await _context.Favorites
            .Where(f => f.UserId == _currentUser.Id.Value)
            .Select(f => new FavoriteItemDto(
                f.Item.Id,
                f.Item.Title,
                f.Item.Pricing.Where(p => p.PricingType == "daily").Select(p => (decimal?)p.Price).FirstOrDefault(),
                f.Item.Images.Where(img => img.IsPrimary).Select(img => img.ImageUrl).FirstOrDefault()
                    ?? f.Item.Images.Select(img => img.ImageUrl).FirstOrDefault(),
                f.Item.City
            ))
            .ToListAsync(ct);

        return new GetMyFavoritesResponse(true, items, null);
    }
}
