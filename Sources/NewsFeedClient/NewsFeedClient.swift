import Foundation

public struct NewsFeedClient {
    private enum Mode {
        case live(apiKey: String, session: URLSession)
        case fixture(NewsPage)
    }

    private let mode: Mode

    private init(mode: Mode) {
        self.mode = mode
    }

    public static func live(
        apiKey: String,
        session: URLSession = .shared
    ) -> NewsFeedClient {
        NewsFeedClient(mode: .live(apiKey: apiKey, session: session))
    }

    public static func fixture(_ page: NewsPage) -> NewsFeedClient {
        NewsFeedClient(mode: .fixture(page))
    }

    public func topHeadlines(_ request: TopHeadlinesRequest) async throws -> NewsPage {
        switch mode {
        case .fixture(let newsPage):
            return newsPage
        case .live(let apiKey, let session):
            let url = NewsAPIURLBuilder.topHeadlines(request)
            return try await perform(url: url, apiKey: apiKey, session: session)
        }
    }

    public func everything(_ request: EverythingRequest) async throws -> NewsPage {
        switch mode {
        case .fixture(let newsPage):
            return newsPage
        case .live(let apiKey, let session):
            let url = NewsAPIURLBuilder.everything(request)
            return try await perform(url: url, apiKey: apiKey, session: session)
        }
    }

    private func perform(
        url: URL,
        apiKey: String,
        session: URLSession
    ) async throws -> NewsPage {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NewsFeedError.transport(error.localizedDescription)
        }

        let statusCode = (response as? HTTPURLResponse)?.statusCode

        switch statusCode {
        case 401:
            throw NewsFeedError.unauthorized
        case 429:
            throw NewsFeedError.rateLimited
        case .some(let code) where (200..<300).contains(code):
            break
        default:
            // Fall through to body decode - NewsAPI often explains erros in JSON.
            break
        }

        let dto: NewsAPIResponseDTO
        do {
            dto = try JSONDecoder().decode(NewsAPIResponseDTO.self, from: data)
        } catch {
            if let code = statusCode, !(200..<300).contains(code) {
                throw NewsFeedError.apiStatus(
                    code: code,
                    message: HTTPURLResponse.localizedString(forStatusCode: code)
                )
            }
            throw NewsFeedError.decoding(error.localizedDescription)
        }

        do {
            return try NewsAPIMapping.newsPage(from: dto)
        } catch let error as NewsFeedError {
            throw error
        } catch {
            throw NewsFeedError.apiStatus(
                code: statusCode,
                message: error.localizedDescription
            )
        }
    }
}
