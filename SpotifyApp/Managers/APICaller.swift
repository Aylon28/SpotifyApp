//
//  APICaller.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
        static let limit20 = "?limit=20"
        
        struct URLs {
            static let profile = "/me"
            static let newReleases = "/browse/new-releases"
            static let featuredPlaylists = "/browse/featured-playlists"
            static let recommendations = "/recommendations"
            static let recommendedGenres = "/recommendations/available-genre-seeds"
            static let albumDetails = "/albums"
            static let playlistDetails = "/playlists"
            static let categories = "/browse/categories"
            static let search = "/search"
            static let userPlaylists = "/me/playlists"
            static let userAlbums = "/me/albums"
        }
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    //MARK: --CATEGORY
    public func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.categories, completion: completion)
    }
    
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<FeaturedPlaylistResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.categories + "/\(category.id)/playlists", completion: completion)
    }
    
    //MARK: --PLAYLIST
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.playlistDetails + "/\(playlist.id)", completion: completion)
    }
    
    public func getCurrentUserPlaylists(completion: @escaping (Result<PlaylistResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.userPlaylists, completion: completion)
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                self?.createRequest(with: URL(string: urlString), type: .POST, completion: { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)

                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        } catch {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                    task.resume()
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .POST, completion: { baseRequest in
            var request = baseRequest
            let json = [
                "uris": ["spotify:track:\(track.id)"]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        })
    }
    
    
    public func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .DELETE, completion: { baseRequest in
            var request = baseRequest
            let json = [
                "tracks": [[
                    "uri": "spotify:track:\(track.id)"
                ]]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        })
        
    }
    
    //MARK: --ALBUMS
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.albumDetails + "/\(album.id)", completion: completion)
    }
    
    public func getCurrentUserAlbums(completion: @escaping (Result<UserAlbumsResponse, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.userAlbums, completion: completion)
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + Constants.URLs.userAlbums + "?ids=\(album.id)"),
                      type: .PUT,
                      completion: { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode,
                      error == nil else {
                    completion(false)
                    return
                }
                completion(code == 200)
            }
            task.resume()
        })
    }
    
    //MARK: --BROWSE
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        performGetTask(urlEnd: Constants.URLs.profile, completion: completion)
    }
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>)) -> Void) {
        performGetTask(urlEnd: Constants.URLs.newReleases + Constants.limit20, completion: completion)
    }
    
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistResponse, Error>)) -> Void) {
        performGetTask(urlEnd: Constants.URLs.featuredPlaylists + Constants.limit20, completion: completion)
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse, Error>)) -> Void) {
        let seeds = genres.joined(separator: ",")
        performGetTask(urlEnd: Constants.URLs.recommendations + Constants.limit20 + "&seed_genres=\(seeds)", completion: completion)
    }
    
    public func getRecommendationGenres(completion: @escaping ((Result<RecommendationGenresResponse, Error>)) -> Void) {
        performGetTask(urlEnd: Constants.URLs.recommendedGenres, completion: completion)
    }
    
    private func performGetTask<T: Codable>(urlEnd: String, completion: @escaping ((Result<T, Error>)) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + urlEnd), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                    print("\(T.Type.self): " + error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
    //MARK: --SEARCH
    public func search(with query: String, completion: @escaping ((Result<SearchResultResponse, Error>)) -> Void) {
        performGetTask(urlEnd: Constants.URLs.search + "?type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")", completion: completion)
    }
    
    //MARK: --HTTP
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
