using Application.Common.Interfaces;
using Domain.Entities;
using Domain.Enums;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.Support;

// ── DTOs ─────────────────────────────────────────────────────────────────────
public record SupportMessageDto(Guid Id, long SenderId, string Message, DateTime CreatedAt);
public record TicketListDto(Guid Id, string Type, string Status, DateTime CreatedAt, string? LastMessage, string? UserName);
public record TicketDetailsDto(Guid Id, string Type, string Status, DateTime CreatedAt, List<SupportMessageDto> Messages, string? UserName);

// ── CREATE TICKET ─────────────────────────────────────────────────────────────

public record CreateTicketCommand(string Type, string Message) : IRequest<CreateTicketResponse>;
public record CreateTicketResponse(bool Success, string? Error, Guid? TicketId, string Status = "open");

public class CreateTicketCommandValidator : AbstractValidator<CreateTicketCommand>
{
    public CreateTicketCommandValidator()
    {
        RuleFor(x => x.Type).NotEmpty();
        RuleFor(x => x.Message).NotEmpty().MaximumLength(2000);
    }
}

public class CreateTicketCommandHandler : IRequestHandler<CreateTicketCommand, CreateTicketResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;
    private readonly IRoleService _roleService;

    public CreateTicketCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier, IRoleService roleService)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _roleService = roleService;
    }

    public async Task<CreateTicketResponse> Handle(CreateTicketCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new CreateTicketResponse(false, "Unauthorized.", null);

        if (!Enum.TryParse<SupportTicketType>(request.Type, true, out var ticketType))
            return new CreateTicketResponse(false, $"Invalid ticket type: {request.Type}", null);

        var ticket = new SupportTicket
        {
            UserId = _currentUser.Id.Value,
            Type = ticketType,
            Status = SupportTicketStatus.Open,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.SupportTickets.Add(ticket);

        _context.SupportMessages.Add(new SupportMessage
        {
            TicketId = ticket.Id,
            SenderId = _currentUser.Id.Value,
            Message = request.Message,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync(ct);

        // Notify Support Agents
        var agents = await _roleService.GetUserIdsInRoleAsync(SecurityRoles.Support.ToString());
        var sender = await _context.Users.FirstOrDefaultAsync(u => u.Id == _currentUser.Id.Value, ct);
        var userName = sender?.FirstName ?? "A user";
        
        await _notifier.SendToUsersAsync(
            agents,
            "New Support Ticket",
            $"{userName} opened a new '{ticketType}' ticket.",
            "support",
            $"/support/tickets/{ticket.Id}",
            ct);

        return new CreateTicketResponse(true, null, ticket.Id);
    }
}

// ── GET TICKETS ───────────────────────────────────────────────────────────────

public record GetTicketsQuery(bool IsSupportAgent = false) : IRequest<GetTicketsResponse>;
public record GetTicketsResponse(List<TicketListDto> Tickets);

public class GetTicketsQueryHandler : IRequestHandler<GetTicketsQuery, GetTicketsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetTicketsQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetTicketsResponse> Handle(GetTicketsQuery request, CancellationToken ct)
    {
        var query = _context.SupportTickets
            .Include(t => t.User)
            .AsQueryable();

        if (!request.IsSupportAgent)
        {
            query = query.Where(t => t.UserId == _currentUser.Id!.Value);
        }

        var tickets = await query
            .OrderByDescending(t => t.UpdatedAt)
            .Select(t => new TicketListDto(
                t.Id, t.Type.ToString(), t.Status.ToString(), t.CreatedAt,
                t.Messages.OrderByDescending(m => m.CreatedAt).Select(m => m.Message).FirstOrDefault(),
                t.User != null ? t.User.FirstName + " " + t.User.LastName : null
            ))
            .ToListAsync(ct);

        return new GetTicketsResponse(tickets);
    }
}

// ── GET TICKET DETAILS ────────────────────────────────────────────────────────

public record GetTicketQuery(Guid Id, bool IsSupportAgent = false) : IRequest<GetTicketResponse>;
public record GetTicketResponse(bool Found, string? Error, TicketDetailsDto? Ticket);

public class GetTicketQueryHandler : IRequestHandler<GetTicketQuery, GetTicketResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;

    public GetTicketQueryHandler(IApplicationDbContext context, IUser currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<GetTicketResponse> Handle(GetTicketQuery request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new GetTicketResponse(false, "Unauthorized.", null);

        var ticket = await _context.SupportTickets
            .Include(t => t.Messages)
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == request.Id, ct);

        if (ticket == null) return new GetTicketResponse(false, "Ticket not found.", null);

        if (!request.IsSupportAgent && ticket.UserId != _currentUser.Id.Value)
            return new GetTicketResponse(false, "Forbidden.", null);

        var dto = new TicketDetailsDto(
            ticket.Id,
            ticket.Type.ToString(),
            ticket.Status.ToString(),
            ticket.CreatedAt,
            ticket.Messages.OrderBy(m => m.CreatedAt).Select(m => new SupportMessageDto(m.Id, m.SenderId, m.Message, m.CreatedAt)).ToList(),
            ticket.User != null ? ticket.User.FirstName + " " + ticket.User.LastName : null
        );

        return new GetTicketResponse(true, null, dto);
    }
}

// ── POST MESSAGE ──────────────────────────────────────────────────────────────

public record PostSupportMessageCommand(Guid TicketId, string Message, bool IsSupportAgent = false) : IRequest<PostSupportMessageResponse>;
public record PostSupportMessageResponse(bool Success, string? Error, Guid? MessageId, string? Message, DateTime? CreatedAt);

public class PostSupportMessageCommandHandler : IRequestHandler<PostSupportMessageCommand, PostSupportMessageResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IUser _currentUser;
    private readonly INotificationSender _notifier;
    private readonly IRoleService _roleService;

    public PostSupportMessageCommandHandler(IApplicationDbContext context, IUser currentUser, INotificationSender notifier, IRoleService roleService)
    {
        _context = context;
        _currentUser = currentUser;
        _notifier = notifier;
        _roleService = roleService;
    }

    public async Task<PostSupportMessageResponse> Handle(PostSupportMessageCommand request, CancellationToken ct)
    {
        if (_currentUser.Id == null)
            return new PostSupportMessageResponse(false, "Unauthorized.", null, null, null);

        var ticket = await _context.SupportTickets.FirstOrDefaultAsync(t => t.Id == request.TicketId, ct);
        if (ticket == null) return new PostSupportMessageResponse(false, "Ticket not found.", null, null, null);

        // Ticket owner or admin/support can message
        if (!request.IsSupportAgent && ticket.UserId != _currentUser.Id.Value)
            return new PostSupportMessageResponse(false, "Forbidden.", null, null, null);

        var msg = new SupportMessage
        {
            TicketId = request.TicketId,
            SenderId = _currentUser.Id.Value,
            Message = request.Message,
            CreatedAt = DateTime.UtcNow
        };
        _context.SupportMessages.Add(msg);
        
        // Auto-transition status
        ticket.Status = request.IsSupportAgent 
            ? SupportTicketStatus.AwaitingCustomer 
            : SupportTicketStatus.AwaitingSupport;

        ticket.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);

        if (request.IsSupportAgent)
        {
            // Notify the user who opened the ticket
            await _notifier.SendToUserAsync(
                ticket.UserId,
                "Support Reply",
                "A support agent has replied to your ticket.",
                "support",
                $"/support/tickets/{ticket.Id}",
                ct);
        }
        else
        {
            // Notify support agents
            var agents = await _roleService.GetUserIdsInRoleAsync(SecurityRoles.Support.ToString());
            await _notifier.SendToUsersAsync(
                agents,
                "New Ticket Message",
                $"New message on ticket #{ticket.Id.ToString().Substring(0, 8)}",
                "support",
                $"/support/tickets/{ticket.Id}",
                ct);
        }

        return new PostSupportMessageResponse(true, null, msg.Id, msg.Message, msg.CreatedAt);
    }
}

// ── UPDATE TICKET STATUS ──────────────────────────────────────────────────────

public record UpdateTicketStatusCommand(Guid TicketId, string Status) : IRequest<UpdateTicketStatusResponse>;
public record UpdateTicketStatusResponse(bool Success, string? Error, Guid? TicketId, string? Status);

public class UpdateTicketStatusCommandHandler : IRequestHandler<UpdateTicketStatusCommand, UpdateTicketStatusResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateTicketStatusCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<UpdateTicketStatusResponse> Handle(UpdateTicketStatusCommand request, CancellationToken ct)
    {
        var ticket = await _context.SupportTickets.FirstOrDefaultAsync(t => t.Id == request.TicketId, ct);
        if (ticket == null) return new UpdateTicketStatusResponse(false, "Ticket not found.", null, null);

        if (!Enum.TryParse<SupportTicketStatus>(request.Status, true, out var status))
            return new UpdateTicketStatusResponse(false, $"Invalid status: {request.Status}", null, null);

        ticket.Status = status;
        ticket.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);
        return new UpdateTicketStatusResponse(true, null, ticket.Id, ticket.Status.ToString());
    }
}
