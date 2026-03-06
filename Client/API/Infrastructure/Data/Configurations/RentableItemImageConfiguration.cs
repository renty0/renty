using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class RentableItemImageConfiguration : IEntityTypeConfiguration<RentableItemImage>
{
    public void Configure(EntityTypeBuilder<RentableItemImage> builder)
    {
        builder.ToTable("RentableItemImages");

        builder.HasKey(i => i.Id);

        builder.Property(i => i.ImageId);

        builder.Property(i => i.ThumbnailUrl)
            .HasMaxLength(1000);

        builder.Property(i => i.AltText)
            .HasMaxLength(200);

        builder.HasOne(i => i.RentableItem)
            .WithMany(r => r.Images)
            .HasForeignKey(i => i.RentableItemId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(i => i.RentableItemId);
        builder.HasIndex(i => new { i.RentableItemId, i.IsPrimary });
    }
}
