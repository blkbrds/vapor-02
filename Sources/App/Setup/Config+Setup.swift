import FluentProvider
import MySQLProvider
import AuthProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        addConfigurable(middleware: ApiMiddleware(), name: "api-middleware")
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(User.self)
        preparations.append(Comment.self)
        preparations.append(Favorite.self)
        preparations.append(ResImage.self)
        preparations.append(Image.self)
        preparations.append(Restaurant.self)
        preparations.append(Notification.self)
        preparations.append(Auth.self)
        preparations.append(Session.self)
    }
}
