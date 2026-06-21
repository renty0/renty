using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

class Program {
    static async Task Main() {
        var client = new HttpClient();
        var content = new StringContent("");
        // Just testing if the endpoint is reachable
        try {
            var response = await client.PutAsync("http://localhost:5106/api/v1/rentals/1d01bdba-4c5d-45ba-9c8b-f63b9feeb8e8/request-expert", content);
            Console.WriteLine((int)response.StatusCode);
            Console.WriteLine(await response.Content.ReadAsStringAsync());
        } catch (Exception e) {
            Console.WriteLine(e.Message);
        }
    }
}
