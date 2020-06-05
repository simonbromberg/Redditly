//
//  TableViewCells.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-05.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
}

class LabelCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}

class ArticleCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
}
