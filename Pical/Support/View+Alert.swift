import SwiftUI

extension View {
    func alert(textBinding: Binding<String?>) -> some View {
        let isPresented = Binding<Bool>(
            get: { textBinding.wrappedValue != nil },
            set: { if !$0 { textBinding.wrappedValue = nil } }
        )

        return alert(
            "Error",
            isPresented: isPresented,
            actions: {
                Button("OK", role: .cancel) { textBinding.wrappedValue = nil }
            },
            message: {
                if let message = textBinding.wrappedValue {
                    Text(message)
                }
            }
        )
    }
}
