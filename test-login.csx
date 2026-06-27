using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

var client = new HttpClient();
var content = new StringContent("{\"email\":\"admin@renty.com\",\"password\":\"Password12!\"}", Encoding.UTF8, "application/json");
var response = await client.PostAsync("http://localhost:5247/api/v1/auth/login", content);
Console.WriteLine($"Status: {response.StatusCode}");
var body = await response.Content.ReadAsStringAsync();
Console.WriteLine(body);
