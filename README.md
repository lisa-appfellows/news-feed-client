# NewsFeedClient

Swift package that talks to [NewsAPI](https://newsapi.org) for the News Portfolio sample app. Owns HTTP, decoding, request types, and typed errors. Does **not** own caching, SwiftUI, SwiftData, images, or AI.

**Platforms:** iOS 17+, macOS 14+ (macOS for `swift test` / CI)  
**Swift:** 5.9+

## Install (SPM)

Add via GitHub URL + **version tag** (not a local path dependency):

```swift
.package(
    url: "https://github.com/lisa-appfellows/news-feed-client.git",
    from: "1.0.0"
)
```

Tag a release before the app depends on `from:`.

## Usage

```swift
import NewsFeedClient

// Production — API key from xcconfig / env, never committed
let live = NewsFeedClient.live(apiKey: apiKey)

let headlines = try await live.topHeadlines(
    TopHeadlinesRequest(country: "us", category: .technology, pageSize: 4)
)

let search = try await live.everything(
    EverythingRequest(q: "swift", language: "en", sortBy: .publishedAt)
)

// Tests / previews — no network
let fixture = NewsFeedClient.fixture(
    NewsPage(
        articles: [Article(title: "Hello", url: "https://example.com")],
        totalResults: 1
    )
)
```

### Endpoints

| Method | NewsAPI | Notes |
|--------|---------|--------|
| `topHeadlines` | `/v2/top-headlines` | `country` + optional `NewsCategory` — no dates |
| `everything` | `/v2/everything` | `q` + optional `from` / `to` / `language` / `SortBy` — no country/category |

Named time frames and UI policy live in the **app**; this package only accepts concrete request values.

### Errors

`NewsFeedError`: `unauthorized`, `rateLimited`, `transport`, `decoding`, `apiStatus`.

## Testing & keys

- Unit tests use **fixtures** and a `URLProtocol` stub — no live NewsAPI calls in CI.
- Run: `swift test`
- Live keys stay local (xcconfig / env). Never commit secrets.

## Intentionally out of scope

Day-boundary cache, image loading, bookmarks, localization, Safari presentation, and future schema/AI work belong in the app. This package is meant to stay stable after v1.
