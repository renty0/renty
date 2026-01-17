using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class CalendarConfiguration : IEntityTypeConfiguration<Calendar>
{
    public void Configure(EntityTypeBuilder<Calendar> builder)
    {
        builder.ToTable("Calendars");

        builder.HasKey(c => c.Date);

        builder.Property(c => c.DayName)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(c => c.MonthName)
            .IsRequired()
            .HasMaxLength(20);

        builder.HasIndex(c => c.Year);
        builder.HasIndex(c => c.Month);
        builder.HasIndex(c => c.Quarter);
        builder.HasIndex(c => new { c.Year, c.Month });
    }
}
