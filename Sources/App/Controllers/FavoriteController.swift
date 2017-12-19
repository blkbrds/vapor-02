//
//  FavoriteController.swift
//  App
//
//  Created by Quang Dang N.K on 12/12/17.
//

final class FavoriteController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try JSON(data: ["favorites": Favorite.all().makeJSON()])
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        let favorite = try req.postFavorite()
        try favorite.save()
        return try Response(status: .ok, json: ["message": "Successful"])
    }
    
    func show(_ req: Request, favorite: Favorite) throws -> ResponseRepresentable {
        return favorite
    }
    
    func makeResource() -> Resource<Favorite> {
        return Resource(index: index,
                        store: store,
                        show: show
        )
    }
}

extension Request {
    func postFavorite() throws -> Favorite {
        guard let json = json else { throw Abort.badRequest }
        return try Favorite(json: json)
    }
}

extension FavoriteController: EmptyInitializable {}
