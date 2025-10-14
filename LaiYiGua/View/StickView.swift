import SwiftUI

struct StickView: View {
    var body: some View {
        Rectangle()
            .fill(Color.brown)
            .frame(width: 10, height: 300)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

#Preview {
    StickView()
}
