import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                HStack {
                                    if message.role == .assistant {
                                        bubble(message)
                                        Spacer(minLength: 40)
                                    } else {
                                        Spacer(minLength: 40)
                                        bubble(message)
                                    }
                                }
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    TextField("Escribe un mensaje...", text: $viewModel.userInput)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isLoading)

                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await viewModel.sendMessage()
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                        }
                        .disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("TD GPT")
        }
    }

    @ViewBuilder
    private func bubble(_ message: ChatLine) -> some View {
        Text(message.content)
            .padding(12)
            .background(message.role == .user ? Color.blue : Color.gray.opacity(0.15))
            .foregroundStyle(message.role == .user ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
    }
}

#Preview {
    ContentView()
}
