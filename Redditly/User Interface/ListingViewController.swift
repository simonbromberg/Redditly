//
//  ListingViewController.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var errorLabel: UILabel!

    var articles = [Article]()
    private let thumbnailCache = ImageCache()

    override func viewDidLoad() {
        super.viewDidLoad()

        getArticles()

        tableView.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let path = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: path, animated: true)
        }
    }

    private func getArticles(_ completion: (() -> Void)? = nil) {
        DataProvider.shared.getArticles { [weak self] result in
            var errorMessage: String?

            switch result {
            case .success(let articles):
                self?.articles = articles
                if articles.count == 0 {
                    errorMessage = NSLocalizedString("No results", comment: "Error message")
                }
            case .failure(let error):
                print(error) // TODO: show error
                self?.articles = []
                errorMessage = error.localizedDescription
            }

            DispatchQueue.main.async {
                self?.tableView.reloadData()

                self?.tableView.tableFooterView?.isHidden = errorMessage == nil
                self?.errorLabel.text = errorMessage

                completion?()
            }
        }
    }

    private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()

    @objc private func pullToRefresh() {
        thumbnailCache.removeAllObjects()

        getArticles { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ArticleCell

        let article = articles[indexPath.row]

        cell.label.text = article.title        

        let image = thumbnailCache[article.id]
        cell.thumbnailImageView.image = image

        if image == nil,
            article.hasThumbnail,
            let link = article.thumbnail,
            let url = URL(string: link) {
            DataProvider.shared.getImageData(with: url) { [weak self] result in
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
                    // TODO: handle error
                }
            }
        }

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let article = articles[indexPath.row]
        var height = ceil(article.title.height(withConstrainedWidth: tableView.frame.width - 40, font: UIFont.systemFont(ofSize: 17))) + 24 // FIXME: font

        if article.hasThumbnail,
            let thumbnailHeight = article.thumbnailHeight {
            height += min(CGFloat(thumbnailHeight), tableView.frame.width - 20) + 2 + 20 // FIXME
        }

        return height
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToArticleDetail",
            let row = tableView.indexPathForSelectedRow?.row,
            let destination = segue.destination as? ArticleViewController {
            let article = articles[row]
            destination.article = article
            destination.image = thumbnailCache[article.id]
        }
    }

    // MARK: - Sorting

    @IBOutlet private var sortButton: UIBarButtonItem!

    private enum SortingCriterion {
        case upvotes, date
        var title: String {
            switch self {
            case .upvotes:
                return NSLocalizedString("By upvotes", comment: "Sorting criterion name")
            case .date:
                return NSLocalizedString("By date", comment: "Sorting criterion name")
            }
        }
    }

    private var activeSortingCriterion = SortingCriterion.date

    @IBAction private func tappedSort() {
        let actionSheet = UIAlertController(title: NSLocalizedString("Select one", comment: "Sort selection title"), message: nil, preferredStyle: .actionSheet)

        let criteria: [SortingCriterion] = [.date, .upvotes]
        for criterion in criteria {
            actionSheet.addAction(UIAlertAction(title: criterion.title, style: .default, handler: { _ in
                switch criterion {
                case .date:
                    self.articles = self.articles.sorted(by: \Article.createdUTC)
                case .upvotes:
                    self.articles = self.articles.sorted(by: \Article.score)
                }

                self.tableView.reloadData()
            }))
        }

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Action title"), style: .cancel, handler: nil))

        actionSheet.popoverPresentationController?.barButtonItem = sortButton

        present(actionSheet, animated: true, completion: nil)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}

extension Sequence {
    /// Based on https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            return a[keyPath: keyPath] > b[keyPath: keyPath]
        }
    }
}
