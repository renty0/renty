using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Features.AdminSettings;

public record GetSettingsQuery : IRequest<GetSettingsResponse>;
public record GetSettingsResponse(bool Success, string? Error, Dictionary<string, string>? Settings);

public class GetSettingsQueryHandler : IRequestHandler<GetSettingsQuery, GetSettingsResponse>
{
    private readonly IApplicationDbContext _context;

    public GetSettingsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<GetSettingsResponse> Handle(GetSettingsQuery request, CancellationToken ct)
    {
        var settingsDict = await _context.SystemSettings
            .ToDictionaryAsync(s => s.Key, s => s.Value, ct);

        return new GetSettingsResponse(true, null, settingsDict);
    }
}


public record UpdateSettingCommand(string Key, string Value, string? Description) : IRequest<UpdateSettingResponse>;
public record UpdateSettingResponse(bool Success, string? Error);

public class UpdateSettingCommandHandler : IRequestHandler<UpdateSettingCommand, UpdateSettingResponse>
{
    private readonly IApplicationDbContext _context;

    public UpdateSettingCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<UpdateSettingResponse> Handle(UpdateSettingCommand request, CancellationToken ct)
    {
        var setting = await _context.SystemSettings.FirstOrDefaultAsync(s => s.Key == request.Key, ct);
        if (setting == null)
        {
            setting = new SystemSetting { Key = request.Key };
            _context.SystemSettings.Add(setting);
        }

        setting.Value = request.Value;
        setting.UpdatedAt = DateTimeOffset.UtcNow;
        if (request.Description != null)
        {
            setting.Description = request.Description;
        }

        await _context.SaveChangesAsync(ct);
        return new UpdateSettingResponse(true, null);
    }
}
