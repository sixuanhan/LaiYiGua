import Foundation

enum AIService {
    static let modelName = "gemini-3.5-flash"
    static let timeoutInterval: TimeInterval = 30

    private static func fallbackAPIKeyFromPlist() -> String {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let apiKey = dict["API_KEY"] as? String else {
            return ""
        }
        return apiKey
    }

    static var apiKey: String {
        get {
            if let saved = UserDefaults.standard.string(forKey: "GoogleAIStudioAPIKey"), !saved.isEmpty {
                return saved
            }

            let plistKey = fallbackAPIKeyFromPlist()
            if !plistKey.isEmpty {
                UserDefaults.standard.set(plistKey, forKey: "GoogleAIStudioAPIKey")
            }
            return plistKey
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "GoogleAIStudioAPIKey")
        }
    }

    static func generateContent(_ prompt: String, apiKey: String? = nil) async throws -> String {
        let effectiveKey = apiKey ?? self.apiKey
        guard !effectiveKey.isEmpty else {
            throw NSError(
                domain: "AIService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Missing Google AI Studio API key"]
            )
        }

        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(effectiveKey)"
        guard let url = URL(string: endpoint) else {
            throw NSError(
                domain: "AIService",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Invalid Google AI Studio URL"]
            )
        }

        let payload: [String: Any] = [
            "contents": [[
                "parts": [[
                    "text": prompt
                ]]
            ]]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw error
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "AIService",
                code: 1003,
                userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]
            )
        }

        if httpResponse.statusCode == 429 || httpResponse.statusCode == 503 {
            throw NSError(
                domain: "AIService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "AI service is busy. Please retry later."]
            )
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let rawText = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "AIService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "API request failed: \(rawText)"]
            )
        }

        do {
            let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
            if let errorMessage = decoded.error?.message, !errorMessage.isEmpty {
                throw NSError(
                    domain: "AIService",
                    code: 1004,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
            }

            if let text = decoded.candidates?.first?.content?.parts?.first?.text, !text.isEmpty {
                return text
            }

            let rawText = String(data: data, encoding: .utf8) ?? ""
            if !rawText.isEmpty {
                return rawText
            }

            throw NSError(
                domain: "AIService",
                code: 1005,
                userInfo: [NSLocalizedDescriptionKey: "Empty AI response"]
            )
        } catch let decodeError as DecodingError {
            let rawText = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "AIService",
                code: 1006,
                userInfo: [NSLocalizedDescriptionKey: "Decode failed: \(decodeError.localizedDescription) Raw: \(rawText)"]
            )
        }
    }
}

private struct GeminiResponse: Decodable {
    let candidates: [Candidate]?
    let error: ErrorPayload?

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }

    struct ErrorPayload: Decodable {
        let message: String?
    }
}
