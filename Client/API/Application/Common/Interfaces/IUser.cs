namespace Application.Common.Interfaces;

public interface IUser
{
    long? Id { get; }
    string? Email { get; }
    string? UserName { get; }
}
