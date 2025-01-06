import Vapor

// Define the Credentials struct outside the route handler
struct Credentials: Content {
    let username: String
    let password: String
}

func routes(_ app: Application) throws {
    // Store the latest credentials in memory
    var latestCredentials: Credentials?

    // Define a POST route to accept credentials
    app.post("credentials") { req -> HTTPStatus in
        // Decode the credentials from the request body
        let credentials = try req.content.decode(Credentials.self)
        
        // Save the received credentials
        latestCredentials = credentials
        print("Received Credentials:")
        print("Username: \(credentials.username)")
        print("Password: \(credentials.password)")

        return .ok
    }

    // Define a GET route to show the latest credentials
    app.get("credentials") { req -> String in
        // Return the latest credentials if available
        if let credentials = latestCredentials {
            return """
            Latest Credentials:
            Username: \(credentials.username)
            Password: \(credentials.password)
            """
        } else {
            return "No credentials found yet."
        }
    }
}
