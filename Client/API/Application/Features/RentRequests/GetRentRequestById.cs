using Application.Common.Interfaces;
using Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.RentRequests;

public record GetRentRequestByIdQuery(long Id) : IRequest<GetRentRequestByIdResponse>;

public record GetRentRequestByIdResponse(
    bool Success,
    string? Message,
    RentRequestDto? Request
);

public class GetRentRequestByIdQueryHandler : IRequestHandler<GetRentRequestByIdQuery, GetRentRequestByIdResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetRentRequestByIdQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetRentRequestByIdResponse> Handle(GetRentRequestByIdQuery request, CancellationToken cancellationToken)
    {
        if (_currentUser.Id == null)
        {
            return new GetRentRequestByIdResponse(false, "User not authenticated.", null);
        }

        var rentRequest = await _context.RentRequests
            .Include(r => r.RentableItem)
            .ThenInclude(ri => ri.Images)
            .Include(r => r.RentableItem.Owner)
            .Include(r => r.Renter)
            .Where(r => r.Id == request.Id)
            .Select(r => new RentRequestDto(
                r.Id,
                r.StartDate,
                r.EndDate,
                r.TotalDays,
                r.DailyRate,
                r.TotalAmount,
                r.SecurityDeposit,
                r.DeliveryFee,
                r.GrandTotal,
                r.Status.ToString(),
                r.Message,
                r.OwnerResponse,
                r.RespondedAt,
                r.CancelledAt,
                r.CancellationReason,
                r.IsDeliveryRequested,
                r.DeliveryAddress,
                r.PickupInstructions,
                r.RentableItemId,
                r.RentableItem.TitleAr,
                r.RentableItem.TitleEn,
                r.RentableItem.Images.Where(i => i.IsPrimary).Select(i => i.Image != null ? i.Image.StoragePath : null).FirstOrDefault()
                    ?? r.RentableItem.Images.OrderBy(i => i.DisplayOrder).Select(i => i.Image != null ? i.Image.StoragePath : null).FirstOrDefault(),
                r.RenterId,
                r.Renter.FirstName + " " + r.Renter.LastName,
                r.Renter.Email,
                r.RentableItem.OwnerId,
                r.RentableItem.Owner.FirstName + " " + r.RentableItem.Owner.LastName,
                r.Created
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (rentRequest == null)
        {
            return new GetRentRequestByIdResponse(false, "Request not found.", null);
        }

        // Check if user has access to this request
        if (rentRequest.RenterId != _currentUser.Id.Value && rentRequest.OwnerId != _currentUser.Id.Value)
        {
            return new GetRentRequestByIdResponse(false, "You don't have access to this request.", null);
        }

        return new GetRentRequestByIdResponse(true, null, rentRequest);
    }
}
