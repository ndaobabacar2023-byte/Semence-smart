db.createCollection("users");
db.createCollection("advisories");

db.users.insertMany([
    {
        username: "admin",
        password: "admin123",
        email: "admin@example.com",
        role: "admin"
    },
    {
        username: "farmer1",
        password: "farmer123",
        email: "farmer1@example.com",
        role: "farmer"
    }
]);

db.advisories.insertMany([
    {
        title: "Pest Control Tips",
        content: "Use neem oil to control pests in your crops.",
        createdAt: new Date()
    },
    {
        title: "Irrigation Techniques",
        content: "Drip irrigation is the most efficient way to water your crops.",
        createdAt: new Date()
    }
]);