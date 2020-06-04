//
//  ListingViewController.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // TODO: provide sort options

    private let thumbnailCache = ImageCache()

    @IBOutlet var tableView: UITableView!

    var articles = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getArticles()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let path = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: path, animated: true)
        }
    }

    private func getArticles() {
        ApiManager.shared.getArticles { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
            case .failure(let error):
                print(error) // TODO: show error
                self?.articles = []
            }

            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let article = articles[indexPath.row]

        cell.textLabel?.text = article.title

        let image = thumbnailCache[article.id]
        cell.imageView?.image = image

        if image == nil,
            article.hasThumbnail,
            let link = article.thumbnail,
            let url = URL(string: link) {
            ApiManager.shared.getImageData(url) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self?.thumbnailCache[article.id] = UIImage(data: data)
                        if self?.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                            self?.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                case .failure(let error):
                    print(error)
                    // TODO: handle erorr
                }
            }
        }

        return cell
    }

    // MARK: UITableViewDelegate

    let margin: CGFloat = 20

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let article = articles[indexPath.row]
        var height = tableView.rowHeight

        if article.hasThumbnail,
            let thumbnailHeight = article.thumbnailHeight {
            height = CGFloat(thumbnailHeight) + margin
        }

        return max(height, tableView.rowHeight)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToArticleDetail",
            let row = tableView.indexPathForSelectedRow?.row,
            let destination = segue.destination as? ArticleViewController {
            destination.article = articles[row]
        }
    }
}

