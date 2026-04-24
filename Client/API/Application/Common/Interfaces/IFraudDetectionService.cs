using Domain.Entities;

namespace Application.Common.Interfaces;

public interface IFraudDetectionService
{
    Task LogActivityAsync(long userId, double riskScore, string decision, string reason, string indicators);
    Task EvaluateOrderAsync(Guid orderId);
    Task EvaluateLoginAsync(long userId, string ipAddress);
}
