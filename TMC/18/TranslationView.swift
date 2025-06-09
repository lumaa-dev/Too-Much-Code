//Made by Lumaa

import SwiftUI
import Translation // this API sucks

struct TranslationView: View {
    
    @State private var englishText: String = "Hello world!"
    @State private var frenchText: String = ""
    
    @State private var translateSheet: Bool = false
    
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            newer
        } else if #available(iOS 17.4, macOS 14.4, *) {
            `public`
        } else {
            Text("Unavailable!")
        }
    }
    
    @available(iOS 17.4, macOS 14.4, *)
    private var `public`: some View {
        List {
            TextField("French", text: $frenchText, prompt: Text("French Text"))
            
            Button {
                translateSheet.toggle()
            } label: {
                Label("Translate", systemImage: "translate")
            }
        }
        .onAppear() {
            self.frenchText = "Bonjour monde !"
        }
        .translationPresentation(isPresented: $translateSheet, text: frenchText)
    }
    
    @available(iOS 18.0, macOS 15.0, *)
    private var newer: some View {
        List {
            TextField("English", text: $englishText, prompt: Text("English Text"))
            if !frenchText.isEmpty {
                Text(frenchText)
                    .translationTask(
                        source: Locale.Language(languageCode: .english),
                        target: Locale.Language(languageCode: .french)
                    ) { session in
                        Task { @MainActor in
                            do {
                                let response = try await session.translate(englishText)
                                frenchText = response.targetText
                            } catch {
                                print(error)
                            }
                        }
                    }
            }
            
            Button {
                frenchText = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    frenchText = "*None*"
                }
            } label: {
                Label("Translate", systemImage: "translate")
            }
        }
    }
}

#Preview {
    TranslationView()
}
