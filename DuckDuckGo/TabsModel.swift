//
//  TabsModel.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Foundation
import Core

public class TabsModel: NSObject, NSCoding {

    private struct NSCodingKeys {
        static let legacyIndex = "currentIndex"
        static let currentIndex = "currentIndex2"
        static let legacyTabs = "tabs"
        static let tabs = "tabs2"
    }

    private var currentIndex: Int?
    private var tabs: [Tab]

    var hasUnread: Bool {
        return tabs.contains(where: { !$0.viewed })
    }
        
    public init(tabs: [Tab] = [], currentIndex: Int? = nil, desktop: Bool) {
        self.tabs = tabs
        self.currentIndex = currentIndex
    }

    public convenience required init?(coder decoder: NSCoder) {
        // we migrated tabs to support uid
        let storedTabs: [Tab]?
        if let legacyTabs = decoder.decodeObject(forKey: NSCodingKeys.legacyTabs) as? [Tab], !legacyTabs.isEmpty {
            storedTabs = legacyTabs
        } else {
            storedTabs = decoder.decodeObject(forKey: NSCodingKeys.tabs) as? [Tab]
        }
        
        guard let tabs = storedTabs else {
            return nil
        }

        var currentIndex: Int?
        if var storedIndex = decoder.decodeObject(forKey: NSCodingKeys.legacyIndex) as? Int {
            if storedIndex < 0 || storedIndex >= tabs.count {
                storedIndex = 0
            }
            currentIndex = storedIndex
        }
        self.init(tabs: tabs, currentIndex: currentIndex, desktop: UIDevice.current.userInterfaceIdiom == .pad)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(tabs, forKey: NSCodingKeys.tabs)
        coder.encode(currentIndex, forKey: NSCodingKeys.currentIndex)
    }

    var currentTab: Tab? {
        guard let currentIndex = currentIndex else { return nil }
        return tabs[currentIndex]
    }

    var count: Int {
        return tabs.count
    }

    var hasActiveTabs: Bool {
        return tabs.count > 1 || tabs.last?.link != nil
    }

    func select(tabAt index: Int) {
        currentIndex = index
    }

    func get(tabAt index: Int) -> Tab {
        return tabs[index]
    }

    func add(tab: Tab) {
        tabs.append(tab)
        currentIndex = tabs.count - 1
    }

    func insert(tab: Tab, at index: Int) {
        tabs.insert(tab, at: max(0, index))
    }
    
    func moveTab(from sourceIndex: Int, to destIndex: Int) {
        guard sourceIndex >= 0, sourceIndex < tabs.count,
            destIndex >= 0, destIndex < tabs.count else {
                return
        }
        
        let previouslyCurrentTab = currentTab
        let tab = tabs.remove(at: sourceIndex)
        tabs.insert(tab, at: destIndex)
        
        if let reselectTab = previouslyCurrentTab {
            currentIndex = indexOf(tab: reselectTab) ?? 0
        }
    }

    func remove(at index: Int) {

        tabs.remove(at: index)
        if tabs.isEmpty {
            currentIndex = nil
            return
        }

        if let current = currentIndex {
            if current == 0 || current < index {
                return
            }
            currentIndex = current - 1
        }
    }

    func remove(tab: Tab) {
        if let index = indexOf(tab: tab) {
            remove(at: index)
        }
    }

    func indexOf(tab: Tab) -> Int? {
        return tabs.firstIndex { $0 === tab }
    }

    func clearAll() {
        tabs.removeAll()
        currentIndex = nil
    }

    func insert(tab: Tab, after afterTab: Tab) {
        guard let index = indexOf(tab: afterTab) else {
            fatalError("No index for tab")
        }
        insert(tab: tab, at: index)
    }

    func select(tab: Tab) {
        currentIndex = indexOf(tab: tab)
    }

    func firstTab(where filter: (Tab) -> Bool) -> Tab? {
        return tabs.first(where: filter)
    }

    func forEach(_ body: (Tab) -> Void) {
        tabs.forEach(body)
    }
}
