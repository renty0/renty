namespace Application.Shared.Utilities;

public static class EmailTemplates
{
    public static string GetEmailConfirmationTemplate(string token)
    {
        return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Email Confirmation</title>
</head>
<body style='margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;'>
    <table role='presentation' style='width: 100%; border-collapse: collapse;'>
        <tr>
            <td style='padding: 40px 0;'>
                <table role='presentation' style='max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>
                    <tr>
                        <td style='background: linear-gradient(135deg, #0c295e 0%, #0c47c5 100%); padding: 40px 30px; text-align: center;'>
                            <h1 style='color: #ffffff; margin: 0; font-size: 28px; font-weight: bold;'>Rently</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding: 40px 30px;'>
                            <h2 style='color: #333333; font-size: 24px; margin-top: 0;'>Confirm Your Email</h2>
                            <p style='color: #666666; font-size: 16px; line-height: 1.6;'>
                                Please use the following code to confirm your email address:
                            </p>
                            <div style='background-color: #f8f9fa; border-radius: 8px; padding: 20px; text-align: center; margin: 30px 0;'>
                                <span style='font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #0c295e;'>{token}</span>
                            </div>
                            <p style='color: #666666; font-size: 14px; line-height: 1.6; margin: 20px 0 0;'>
                                This code will expire in 10 minutes. If you didn't request this code, please ignore this email.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
    }
}
