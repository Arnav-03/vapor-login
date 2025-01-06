import Vapor

func routes(_ app: Application) throws {
    // Store the latest credentials in memory
    var latestCredentials: Credentials?

    // Define a POST route to accept credentials
    app.post("credentials") { req -> HTTPStatus in
        // Decode the credentials from the request body
        struct Credentials: Content {
            let username: String
            let password: String
        }

        // Decode and save the received credentials
        latestCredentials = try req.content.decode(Credentials.self)
        print("Received Credentials:")
        print("Username: \(latestCredentials?.username ?? "N/A")")
        print("Password: \(latestCredentials?.password ?? "N/A")")

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
