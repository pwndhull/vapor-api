	//
	//  SongController.swift
	//
	//
	//  Created by Macintosh on 05/09/22.
	//

import Fluent
import Vapor

struct SongController: RouteCollection{
	func boot(routes: Vapor.RoutesBuilder) throws {
		let songs = routes.grouped("songs")
		songs.get(use:index)
		songs.post(use:create)
		songs.put(use:update)
		songs.group(":songID") { song in
			songs.delete(use:delete)
		}
	}
	
		//  MARK: - Get All Songs Route
	func index(req:Request) throws -> EventLoopFuture<[Song]>{
		return Song.query(on:req.db).all()
	}
	
		//  MARK: - Create/Add New Song Request
	func create(req:Request) throws -> EventLoopFuture<HTTPStatus>{
		let song = try req.content.decode(Song.self)
			//		var status : HTTPStatus?
			//		songs.forEach { item in
			//			status = item.save(on: req.db).transform(to: .ok)//item.save(on: req.db).transform(to: .ok)
			//		}
			//		return status ?? HTTPStatus.internalServerError
		return song.save(on:req.db).transform(to: .ok)
	}
	
	
		//	MARK: - Update Song Request
	func update(req:Request) throws -> EventLoopFuture<HTTPStatus> {
		let song = try req.content.decode(Song.self)
		return Song.find(song.id, on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap {
				$0.title = song.title
				return $0.update(on: req.db).transform(to: .ok)
			}
	}
	
		//	MARK: - Delete Song Route
	func delete(req:Request) throws -> EventLoopFuture<HTTPStatus> {
		Song.find(req.parameters.get("songID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap {
				$0.delete(on: req.db)
			}.transform(to: .ok)
	}
}
