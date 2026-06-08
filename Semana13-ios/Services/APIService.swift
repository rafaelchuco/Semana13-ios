import Foundation

final class APIService {
    private let urlString = "http://192.168.17.11:3000/api/chat/completions"
    private let apiKey = "sk-dff9539513a84efeb053a539d75193d2"
    private let modelName = "google/gemma-4-26B-A4B-it"

    func fetchChatResponse(userPrompt: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let userMessage = ChatMessage(role: "user", content: userPrompt)
        let requestBody = ChatRequest(model: modelName, messages: [userMessage], stream: false)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse.choices.first?.message.content ?? "Sin respuesta"
    }
}
