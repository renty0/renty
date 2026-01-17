using System.ComponentModel.DataAnnotations.Schema;
using MediatR;

namespace Domain.Common;

public abstract class BaseEntity
{
    public long Id { get; set; }

    private readonly List<INotification> _domainEvents = new();

    [NotMapped]
    public IReadOnlyCollection<INotification> DomainEvents => _domainEvents.AsReadOnly();

    public void AddDomainEvent(INotification domainEvent)
    {
        _domainEvents.Add(domainEvent);
    }

    public void RemoveDomainEvent(INotification domainEvent)
    {
        _domainEvents.Remove(domainEvent);
    }

    public void ClearDomainEvents()
    {
        _domainEvents.Clear();
    }
}
