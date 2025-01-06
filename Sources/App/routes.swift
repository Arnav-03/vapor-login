import Vapor

// Define the Credentials struct outside the route handler
struct Credentials: Content {
    let username: String
    let password: String
}

func routes(_ app: Application) throws {
    // Define the root route to display a custom message
    app.get { req in
        return "Hello to Vapor server"
    }

    // Store the latest credentials in memory
    var latestCredentials: Credentials?

    // Define a POST route to accept credentials
    app.post("credentials") { req -> HTTPStatus in
        // Decode the credentials from the request body
        let credentials = try req.content.decode(Credentials.self)
        
        // Save the received credentials
        latestCredentials = credentials
        print("Received Credentials are:")
        print("Hello : \(credentials.username)")
        print("Your Password: \(credentials.password)")

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

    app.on(.POST, "process-video") { req -> String in
        // Attempt to get the body content as a string (form data)
        guard let body = req.body.string else {
            throw Abort(.badRequest, reason: "No formData provided.")
        }
        print("Received Form Data:")
        print(body)


        // Return the form data as a string in the response
        return body
    }
}

func configure(_ app: Application) throws {
    // Enable CORS middleware with specific configuration
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .originBased, // This will mirror the request origin
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith,
            .userAgent,
            .accessControlAllowOrigin,
            .accessControlAllowHeaders
        ],
        allowCredentials: true,
        exposedHeaders: [
            .accessControlAllowOrigin,
            .accessControlAllowHeaders
        ]
    )
    
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
    
    // Register routes
    try routes(app)
}
