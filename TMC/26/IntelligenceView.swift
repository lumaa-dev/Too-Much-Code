// Made by Lumaa
// Doesn't work on macOS 15 (Running on Sim iOS 26)

import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
struct IntelligenceView: View {
    private var model: SystemLanguageModel = SystemLanguageModel.default

    @State private var inputText: String = ""
    @State private var messages: [Self.Message] = []
    @State private var isGenerating: Bool = false

    var body: some View {
        switch model.availability {
            case .available:
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            ForEach(self.messages) { message in
                                messageView(message)
                            }

                            if isGenerating {
                                messageView(.init("Generating...", isUser: false), foreground: Color.secondary)
                            }
                        }
                        .navigationTitle(Text("AI Chat"))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        TextField(text: $inputText, prompt: Text("Talk to Apple Intelligence...")) {
                            Text("Talk to Apple Intelligence")
                        }
                        .labelsHidden()
                        .onSubmit {
                            Task {
                                await self.intelligenceMessage()
                            }
                        }
                    }
                }
            case .unavailable(_):
                unavailable
        }
    }

    private func intelligenceMessage() async {
        self.isGenerating = true

        do {
            defer { self.isGenerating = false }
            let session = LanguageModelSession()
            self.messages.append(.init(self.inputText, isUser: true))
            self.inputText = ""

            let response = try await session.respond(to: inputText)

            self.messages.append(.init(response.content, isUser: false))
        } catch {
            print(error)
        }
    }

    @ViewBuilder
    private func messageView(_ message: Self.Message, foreground: Color = Color(uiColor: UIColor.label)) -> some View {
        ZStack {
            Text(message.content)
                .foregroundStyle(foreground)
                .multilineTextAlignment(.leading)
                .font(.callout)
                .frame(maxWidth: 200, alignment: message.isUser ? .trailing : .leading)
                .padding(.vertical)
                .background(message.isUser ? Color.blue.gradient : Color.gray.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }

    private var unavailable: some View {
        ContentUnavailableView("Intelligence Unavailable", systemImage: "apple.intelligence.badge.xmark", description: Text("Apple Intelligence doesn't seem to be available at the moment."))
    }

    struct Message: Identifiable {
        let id: String
        let content: String
        let isUser: Bool

        init(id: String = UUID().uuidString, _ content: String, isUser: Bool) {
            self.id = id
            self.content = content
            self.isUser = isUser
        }
    }
}
