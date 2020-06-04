//
//  ArticleViewController.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    var article: Article?

    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = article?.title
   }
}
