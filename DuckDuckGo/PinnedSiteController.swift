//
//  PinnedSiteController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Core

class PinnedSiteController: UIViewController {

    @IBOutlet weak var tabContainer: UIView!
    @IBOutlet weak var navigationContainer: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var homeButton: UIBarButtonItem!

    weak var tabViewController: TabViewController!
    var pinnedHost: String! {
        didSet {
            if tabViewController != nil {
                reload()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("***", Self.self, #function)

        applyTheme(ThemeManager.shared.currentTheme)

        let url = URL(string: "https://\(pinnedHost!)")!
        let tab = Tab(link: Link(title: nil, url: url))
        let tabController = TabViewController.loadFromStoryboard(model: tab)
        tabController.isLinkPreview = true
        tabController.decorate(with: ThemeManager.shared.currentTheme)
        tabController.attachWebView(configuration: .persistent(), andLoadRequest: URLRequest(url: url), consumeCookies: false)
        tabController.loadViewIfNeeded()

        addChild(tabController)
        tabController.view.frame = tabContainer.bounds
        tabContainer.addSubview(tabController.view)
        tabController.didMove(toParent: self)

        self.tabViewController = tabController

        navigationBar.topItem?.title = pinnedHost
    }

    @IBAction func homeAction() {
        dismiss(animated: false)
        (presentingViewController as? MainViewController)?.showTabSwitcherWithFocus(false)
    }

    func reload() {
        guard tabViewController != nil else { return }
        let url = URL(string: "https://\(pinnedHost!)")!
        tabViewController.load(url: url)
        navigationBar.topItem?.title = pinnedHost
    }

}

extension PinnedSiteController {

    static func loadFromStoryboard() -> PinnedSiteController {
        let storyboard = UIStoryboard(name: "PinnedSite", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? PinnedSiteController else {
            fatalError()
        }
        return controller
    }

}

extension PinnedSiteController: Themable {

    func decorate(with theme: Theme) {
        navigationContainer.backgroundColor = theme.barBackgroundColor
        homeButton.tintColor = theme.barTintColor
    }

}
