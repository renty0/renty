using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

class Program
{
    static void Main()
    {
        string token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZW1haWwiOiJhZG1pbkByZW50bHkuY29tIiwianRpIjoiNzgwZjA2YzktNmQ2My00NjYxLWJlMWEtZWFlNzhlOTY2ZjIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6ImFkbWluQHJlbnRseS5jb20iLCJmaXJzdE5hbWUiOiJTdXBlciIsImxhc3ROYW1lIjoiQWRtaW4iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOlsiU3VwZXJBZG1pbiIsIkFkbWluIl0sImV4cCI6MTc3Mzc0MzUyMSwiaXNzIjoiUmVudGx5LkFQSSIsImF1ZCI6IlJlbnRseS5DbGllbnQifQ.WzGFfZQPcmKgqIJmdK9baK1sSOd8879-VH9t9-gHY98";
        string key = "YourSuperSecretKeyThatIsAtLeast32CharactersLong!";
        string issuer = "Rently.API";
        string audience = "Rently.Client";

        var validationParams = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = false, // Ignore expiration for testing
            ValidateIssuerSigningKey = true,
            ValidIssuer = issuer,
            ValidAudience = audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key))
        };

        try
        {
            var handler = new JwtSecurityTokenHandler();
            handler.ValidateToken(token, validationParams, out var validatedToken);
            Console.WriteLine("Token is VALID!");
        }
        catch (Exception ex)
        {
            Console.WriteLine("Token is INVALID!");
            Console.WriteLine(ex.GetType().Name);
            Console.WriteLine(ex.Message);
        }
    }
}
