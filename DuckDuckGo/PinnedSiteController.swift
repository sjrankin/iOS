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
    @IBOutlet weak var switcherButton: UIBarButtonItem!

    weak var tabViewController: TabViewController!
    var pinnedHost: String! {
        didSet {
            PinnedSiteStore.shared.touch(pinnedHost)
            if tabViewController != nil {
                reloadPinnedSite()
                refreshSwitcherMenu()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("***", Self.self, #function)

        setupTabController()
        applyTheme(ThemeManager.shared.currentTheme)
        navigationBar.topItem?.title = pinnedHost
        reloadPinnedSite()
        refreshSwitcherMenu()
    }

    @IBAction func homeAction() {
        dismiss(animated: false)
        (presentingViewController as? MainViewController)?.showTabSwitcherWithFocus(false)
    }

    func reloadPinnedSite() {
        guard tabViewController != nil else { return }
        let url = URL(string: "https://\(pinnedHost!)")!
        tabViewController.load(url: url)
        navigationBar.topItem?.title = pinnedHost
    }

    private func refreshSwitcherMenu() {

        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        self.switcherButton.customView = imageView
        imageView.loadFavicon(forDomain: pinnedHost, usingCache: .tabs) { image, _ in
            guard let image = image else { return }
            imageView.image = self.imageWithImage(image: image, scaledToSize: .init(width: 32, height: 32))
        }

        if #available(iOS 13.0, *) {
            imageView.addInteraction(UIContextMenuInteraction(delegate: self))
        }
    }

    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: .init(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    private func setupTabController() {

        let url = URL(string: "https://\(pinnedHost!)")!
        let tab = Tab(link: Link(title: nil, url: url))
        let tabController = TabViewController.loadFromStoryboard(model: tab)
        tabController.isLinkPreview = true
        tabController.decorate(with: ThemeManager.shared.currentTheme)
        tabController.attachWebView(configuration: .persistent(), andLoadRequest: nil, consumeCookies: true)
        tabController.loadViewIfNeeded()

        addChild(tabController)
        tabController.view.frame = tabContainer.bounds
        tabContainer.addSubview(tabController.view)
        tabController.didMove(toParent: self)

        self.tabViewController = tabController

        reloadPinnedSite()
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

@available(iOS 13.0, *)
extension PinnedSiteController: UIContextMenuInteractionDelegate {

    func makeContextMenu() -> UIMenu {
        var children = [UIAction]()

        PinnedSiteStore.shared.forEach { host in
            guard host != pinnedHost else { return }
            let image = Favicons.shared.quickLoad(forDomain: host)
            let action = UIAction(title: host, image: image, identifier: nil, discoverabilityTitle: nil) { _ in
                print("***", #function, host)
                self.pinnedHost = host
            }
            children.append(action)
        }

        children.append(UIAction(title: "Unpin", image: UIImage(systemName: "delete"), attributes: .destructive) { _ in
            print("***", #function, "unpin")

        })

        return UIMenu(title: "Pinned Apps", children: children)
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint)
            -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            return self.makeContextMenu()
        })
    }

}

extension PinnedSiteController: Themable {

    func decorate(with theme: Theme) {
        navigationContainer.backgroundColor = theme.barBackgroundColor
        homeButton.tintColor = theme.barTintColor
    }

}
