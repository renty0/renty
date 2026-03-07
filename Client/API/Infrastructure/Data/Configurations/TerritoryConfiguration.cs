using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class TerritoryConfiguration : IEntityTypeConfiguration<Territory>
{
    public void Configure(EntityTypeBuilder<Territory> builder)
    {
        builder.ToTable("Territories");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Region)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(t => t.Country)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(t => t.Continent)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasIndex(t => t.Region);
        builder.HasIndex(t => t.Country);
        builder.HasIndex(t => t.Continent);
        builder.HasIndex(t => new { t.Continent, t.Country, t.Region });
    }
}
