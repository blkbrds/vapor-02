import Vapor

extension Droplet {

    struct Keys {
        static let create = "create"
        static let users = "users"
        static let comments = "comments"
    }

    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }
        
        try resource("comments", CommentController.self)
        try resource("favorites", FavoriteController.self)
        try resource("resimages", ResImageController.self)
        try resource("images", ImageController.self)
        try resource("restaurants", RestaurantController.self)

        let userGroup = grouped(Keys.users)
        userGroup.post(Keys.create, handler: createUser) //http://localhost:8080/users/create
        userGroup.get(User.parameter, handler: getUser) //http://localhost:8080/users/1
        userGroup.get(User.parameter, Keys.comments, handler: getUserComments) //http://localhost:8080/users/1/commments

        let commentGroup = grouped(Keys.comments)
        commentGroup.post(Keys.create, handler: createComment) //http://localhost:8080/comments/create
        commentGroup.get(Comment.parameter, Keys.users, handler: getUserFromComment) //http://localhost:8080/comments/1/users

        get("description") { req in return req.description }
        try resource("posts", PostController.self)
        try resource(Keys.users, UserController.self)
        try resource(Keys.comments, CommentController.self)
    }
}

extension Droplet {

    // User group
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        let user = try User(json: json)
        try user.save()
        return user
    }

    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
    }

    func getUserComments(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return try user.comments.all().makeJSON()
    }
}

extension Droplet {

    func createComment(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        let comment = try Comment(json: json)
        try comment.save()
        return comment
    }

    func getUserFromComment(_ req: Request) throws -> ResponseRepresentable {
        let comment = try req.parameters.next(Comment.self)
        guard let user = try comment.user.get() else {
            throw Abort.notFound
        }
        return user
    }
}
