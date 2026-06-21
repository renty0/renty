using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Moq;
using EntityFrameworkCoreMock;
public class Test {
    public void M() {
        var users = new List<string> { "a", "b" };
        var mock = new DbSetMock<string>(users, x => x);
    }
}
