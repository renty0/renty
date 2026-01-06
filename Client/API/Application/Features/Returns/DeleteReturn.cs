using Application.Common.Interfaces;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Returns;

public record DeleteReturnCommand(long Id) : IRequest<DeleteReturnResponse>;

public record DeleteReturnResponse(
    bool Success,
    string? Message
);

public class DeleteReturnCommandValidator : AbstractValidator<DeleteReturnCommand>
{
    public DeleteReturnCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("Invalid return ID.");
    }
}

public class DeleteReturnCommandHandler : IRequestHandler<DeleteReturnCommand, DeleteReturnResponse>
{
    private readonly IApplicationDbContext _context;

    public DeleteReturnCommandHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DeleteReturnResponse> Handle(DeleteReturnCommand request, CancellationToken cancellationToken)
    {
        var returnItem = await _context.Returns
            .FirstOrDefaultAsync(r => r.Id == request.Id, cancellationToken);

        if (returnItem == null)
        {
            return new DeleteReturnResponse(false, "Return not found.");
        }

        _context.Returns.Remove(returnItem);
        await _context.SaveChangesAsync(cancellationToken);

        return new DeleteReturnResponse(true, "Return deleted successfully.");
    }
}
