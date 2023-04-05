//
//  LibraryPlaylistsViewController.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 27.03.23.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private var playlists: [Playlist] = []
    private let noPlaylistsView = ActionLabelView()
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)

        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        fetchPlaylists()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

    private func fetchPlaylists() {
        var userID: String!
        
        if selectionHandler != nil {
            APICaller.shared.getCurrentUserProfile { result in
                switch result {
                case .success(let user):
                    userID = user.id
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    if userID != nil {
                        self?.playlists = playlists.items.filter { $0.owner.id == userID }
                    } else {
                        self?.playlists = playlists.items
                    }
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI() {
        if playlists.isEmpty {
            setUpNoPlaylistsView()
            tableView.isHidden = true
        } else {
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func setUpNoPlaylistsView() {
        view.addSubview(noPlaylistsView)
        noPlaylistsView.configure(with: ActionLabelViewViewModel(text: "You don't have any playlists", actionTitle: "Create"))
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: view.width/1.5, height: 150)
        noPlaylistsView.center = view.center
        noPlaylistsView.isHidden = false
        noPlaylistsView.delegate = self
    }
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard selectionHandler == nil else {
            selectionHandler?(playlists[indexPath.row])
            dismiss(animated: true)
            return
        }
        
        let playlist = playlists[indexPath.row]
        let vc = PlaylistViewController(playlist: playlist)
        vc.title = playlist.name
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name,
                                                                        subtitle: playlist.owner.display_name,
                                                                        artworkURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
    
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New playlist", message: "Enter playlist name", preferredStyle: .alert)
        alert.addTextField {textField in
            textField.placeholder = "Playlist name..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    self?.fetchPlaylists()
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                    print("Failed to create playlist")
                }
            }
        })
        present(alert, animated: true)
    }
    
}
