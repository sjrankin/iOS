//
//  PinnedSiteStore.swift
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

import Foundation

public class PinnedSiteStore {

    public static let shared = PinnedSiteStore()

    private var hosts = [
        "mobile.twitter.com",
        "m.facebook.com"
    ]

    public var count: Int {
        return hosts.count
    }

    public func isPinned(_ host: String?) -> Bool {
        guard let host = host else { return false }
        return hosts.contains(host)
    }

    public func pin(_ host: String?) {
        guard let host = host else { return }
        unpin(host)
        hosts.insert(host, at: 0)
    }

    public func touch(_ host: String?) {
        pin(host)
    }

    public func unpin(_ host: String?) {
        guard let host = host, let index = hosts.firstIndex(of: host) else { return }
        hosts.remove(at: index)
    }

    public func pinnedSite(at index: Int) -> String? {
        return hosts[index]
    }

}
