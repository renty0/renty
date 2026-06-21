using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using System;

var client = new HttpClient();
var res = await client.GetAsync("http://localhost:5106/api/v1/rentals");
var json = await res.Content.ReadAsStringAsync();
Console.WriteLine(json);
