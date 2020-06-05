//
//  ArticleViewController.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit
import MarkdownKit

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var article: Article!
    var image: UIImage?

    private enum CellType {
        case image, title, body, score
        var identifier: String {
            switch self {
            case .image:
                return "thumbnail"
            case .title, .body, .score:
                return "title"
            }
        }
    }

    private var cells = [CellType]()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if article.hasThumbnail {
            cells.append(.image)
        }

        if !article.title.isEmpty {
            cells.append(.title)
        }

        if !article.body.isEmpty {
            cells.append(.body)
        }

        cells.append(.score)

        tableView.rowHeight = UITableView.automaticDimension
   }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = cells[indexPath.row]

        switch type {
        case .title:
            let cell: LabelCell = tableView.dequeueReusableCell(for: indexPath, identifier: type.identifier)
            cell.label.textColor = .black
            cell.label.font = UIFont.boldSystemFont(ofSize: 17)

            cell.label.text = article.title

            return cell
        case .body:
            let cell: LabelCell = tableView.dequeueReusableCell(for: indexPath, identifier: type.identifier)
            cell.label.font = UIFont.systemFont(ofSize: 14)
            cell.label.textColor = .black
            cell.label.attributedText = markdownParser.parse(article.body)
            
            return cell
        case .score:
            let cell: LabelCell = tableView.dequeueReusableCell(for: indexPath, identifier: type.identifier)
            cell.label.font = UIFont.systemFont(ofSize: 14)
            cell.label.textColor = .gray

            let dateString = dateFormatter.string(from: article.createdDate)
            cell.label.text = "Score: \(numberFormatter.string(from: NSNumber(value: article.score))!) Upvote ratio: \(article.upvoteRatio)\n\(dateString)"

            return cell
        case .image:
            let cell: ImageCell = tableView.dequeueReusableCell(for: indexPath, identifier: type.identifier)
            cell.thumbnailImageView.image = image
            
            if image == nil,
                article.hasThumbnail,
                let url = article.thumbnailURL {
                ApiManager.shared.getImageData(url) { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.image = UIImage(data: data)
                        DispatchQueue.main.async {
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    case .failure(let error):
                        print(error) // TODO: show error, eg show broken placeholder
                    }
                }
            }

            return cell
        }
    }

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var markdownParser: MarkdownParser = {
        let parser = MarkdownParser()
        return parser
    }()

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let type = cells[indexPath.row]

        switch type {
        case .title, .image:
            if let url = article.articleURL,
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
}
