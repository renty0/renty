using Domain.Common;
using System.ComponentModel.DataAnnotations.Schema;

using System.ComponentModel.DataAnnotations.Schema;

namespace Domain.Entities;

public class ProductImage : BaseEntity
{
    public Guid ImageId { get; set; }
    [ForeignKey(nameof(ImageId))]
    public virtual MediaFile? Image { get; set; }
    public bool IsPrimary { get; set; } = false;
    public int DisplayOrder { get; set; } = 0;

    public long ProductId { get; set; }
    
    [ForeignKey("ProductId")]
    public Product Product { get; set; } = null!;
}
