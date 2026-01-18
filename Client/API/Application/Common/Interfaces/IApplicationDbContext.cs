using Domain.Entities;

using Microsoft.EntityFrameworkCore;

namespace Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<RefreshToken> RefreshTokens { get; }
    DbSet<ProductCategory> ProductCategories { get; }
    DbSet<ProductSubcategory> ProductSubcategories { get; }
    DbSet<Product> Products { get; }
    DbSet<Calendar> Calendars { get; }
    DbSet<Territory> Territories { get; }
    DbSet<Customer> Customers { get; }
    DbSet<Sale> Sales { get; }
    DbSet<Return> Returns { get; }
    DbSet<RentableItem> RentableItems { get; }
    DbSet<RentableItemImage> RentableItemImages { get; }
    DbSet<RentRequest> RentRequests { get; }
    DbSet<MediaFile> MediaFiles { get; }
    DbSet<ProductImage> ProductImages { get; }
    DbSet<GapAnalysisResult> GapAnalysisResults { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
