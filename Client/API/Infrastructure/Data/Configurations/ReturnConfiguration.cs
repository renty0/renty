using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class ReturnConfiguration : IEntityTypeConfiguration<Return>
{
    public void Configure(EntityTypeBuilder<Return> builder)
    {
        builder.ToTable("Returns");

        builder.HasKey(r => r.Id);

        builder.Property(r => r.ReturnReason)
            .HasMaxLength(500);

        builder.HasOne(r => r.Product)
            .WithMany(p => p.Returns)
            .HasForeignKey(r => r.ProductId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Territory)
            .WithMany(t => t.Returns)
            .HasForeignKey(r => r.TerritoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.ReturnCalendar)
            .WithMany(c => c.Returns)
            .HasForeignKey(r => r.ReturnDate)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Ignore(r => r.ReturnValue);

        builder.HasIndex(r => r.ReturnDate);
        builder.HasIndex(r => r.ProductId);
        builder.HasIndex(r => r.TerritoryId);
        builder.HasIndex(r => new { r.ReturnDate, r.TerritoryId });
    }
}
