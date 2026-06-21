using System.IO;
File.AppendAllText("/tmp/debug.txt", $"Owner: {owner.Id}, Balance: {owner.WalletBalance}, Share: {ownerShare}\n");
