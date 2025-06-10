// Made by Lumaa

import SwiftUI
import Combine

struct URLSessionView: View {
    @State private var responseText: String = ""
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        List {
            Section(header: Text("Asynchronous Data")) {
                Button {
                    Task {
                        await self.sendRequest(URL(string: "https://record.lumaa.fr/api/version"))
                    }
                } label: {
                    Text(String("Send remote request"))
                }

                Button {
                    Task {
                        await self.sendRequest(URL(string: "http://192.168.1.120:3000/api/version")) // run local RecordLink Nuxt server
                    }
                } label: {
                    Text(String("Send local request"))
                }
            }

            Section(header: Text("Data Task")) {
                Button {
                    self.sendDataTaskReq(URL(string: "https://record.lumaa.fr/api/version"))
                } label: {
                    Text(String("Send remote request"))
                }

                Button {
                    self.sendDataTaskReq(URL(string: "http://192.168.1.120:3000/api/version")) // run local RecordLink Nuxt server
                } label: {
                    Text(String("Send local request"))
                }
            }

            Text(responseText.isEmpty ? "[No response]" : responseText)
        }
    }

    private func sendRequest(_ url: URL?) async {
        guard let url else { return }

        if let (data, res) = try? await URLSession.shared.data(for: .init(url: url)), let httpres = res as? HTTPURLResponse {
            guard httpres.statusCode == 200 else { return }
            self.responseText = String(data: data, encoding: .utf8) ?? "[Unknown response]"
        }
    }

    private func sendDataTaskReq(_ url: URL?) {
        guard let url else { return }

        URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        print("Finished request")
                    case let .failure(err):
                        print(err)
                }
            } receiveValue: { data in
                self.responseText = String(data: data, encoding: .utf8) ?? "[Unknown response]"
            }
            .store(in: &cancellables)
    }
}

#Preview {
    URLSessionView()
}
