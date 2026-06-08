import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var messages: [ChatLine] = [
        ChatLine(role: .assistant, content: "Hola! ¿En qué puedo ayudarte?")
    ]
    @Published var isLoading: Bool = false

    private let apiService = APIService()

    func sendMessage() async {
        let prompt = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        isLoading = true
        messages.append(ChatLine(role: .user, content: prompt))
        userInput = ""

        do {
            let response = try await apiService.fetchChatResponse(userPrompt: prompt)
            messages.append(ChatLine(role: .assistant, content: response))
        } catch {
            messages.append(ChatLine(role: .assistant, content: "Error: \(error.localizedDescription)"))
        }

        isLoading = false
    }
}

struct ChatLine: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let content: String
}
