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

     // Define the POST route to process the video
    app.on(.POST, "process-video") { req -> HTTPStatus in
        // Attempt to extract the video from the form data
        guard let video = req.body.formData?.first(where: { $0.name == "video" }) else {
            throw Abort(.badRequest, reason: "No video file found in form data.")
        }

        // Create a directory to store the video (if it doesn't exist)
        let fileManager = FileManager.default
        let directory = app.directory.workingDirectory + "processed-videos"
        if !fileManager.fileExists(atPath: directory) {
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        }

        // Generate a unique filename for the uploaded video
        let filename = UUID().uuidString + ".mp4"
        let filePath = directory + "/" + filename

        // Save the video to the server
        try video.data.write(to: URL(fileURLWithPath: filePath))

        print("Video saved at: \(filePath)")

        // Return the download link for the saved video
        let downloadLink = "http://localhost:8080/processed-videos/\(filename)"
        print("Download link: \(downloadLink)")

        return downloadLink
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
