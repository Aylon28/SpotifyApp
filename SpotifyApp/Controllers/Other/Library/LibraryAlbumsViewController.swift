//
//  LibraryAlbumsViewController.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 27.03.23.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private var albums: [Album] = []
    private let noAlbumsView = ActionLabelView()
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)

        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        fetchAlbums()
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification,
                                                          object: nil,
                                                          queue: .main,
                                                          using: { [weak self] _ in
            self?.fetchAlbums()
        })
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

    private func fetchAlbums() {
        albums = []
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    for item in albums.items {
                        self?.albums.append(item.album)
                    }
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI() {
        if albums.isEmpty {
            setUpNoAlbumsView()
            tableView.isHidden = true
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func setUpNoAlbumsView() {
        view.addSubview(noAlbumsView)
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You don't have any saved albums yet", actionTitle: "Add"))
        noAlbumsView.frame = CGRect(x: (view.width-(view.width/1.5))/2, y: (view.height-150)/2, width: view.width/1.5, height: 150)
        noAlbumsView.isHidden = false
        noAlbumsView.delegate = self
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.title = album.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name,
                                                                        subtitle: album.artists.first?.name ?? "-",
                                                                        artworkURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
}
