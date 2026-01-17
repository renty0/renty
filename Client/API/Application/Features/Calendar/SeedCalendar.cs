using Application.Common.Interfaces;
using FluentValidation;
using MediatR;

namespace Application.Features.Calendar;

public record SeedCalendarCommand(int StartYear, int EndYear) : IRequest<SeedCalendarResponse>;

public record SeedCalendarResponse(
    bool Success,
    string? Message
);

public class SeedCalendarCommandValidator : AbstractValidator<SeedCalendarCommand>
{
    public SeedCalendarCommandValidator()
    {
        RuleFor(x => x.StartYear)
            .GreaterThan(1900).WithMessage("Start year must be greater than 1900.")
            .LessThanOrEqualTo(x => x.EndYear).WithMessage("Start year must be less than or equal to end year.");

        RuleFor(x => x.EndYear)
            .LessThanOrEqualTo(2100).WithMessage("End year must be less than or equal to 2100.");
    }
}

public class SeedCalendarCommandHandler : IRequestHandler<SeedCalendarCommand, SeedCalendarResponse>
{
    private readonly ICalendarService _calendarService;

    public SeedCalendarCommandHandler(ICalendarService calendarService)
    {
        _calendarService = calendarService;
    }

    public async Task<SeedCalendarResponse> Handle(SeedCalendarCommand request, CancellationToken cancellationToken)
    {
        await _calendarService.SeedCalendarAsync(request.StartYear, request.EndYear, cancellationToken);
        return new SeedCalendarResponse(true, $"Calendar seeded from {request.StartYear} to {request.EndYear}.");
    }
}
