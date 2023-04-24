//

import SwiftUI

struct DirectionItem: Identifiable {
    var id = UUID()
    var icon: Image
    var text: String
}

let sample: [DirectionItem] = [
    .init(icon: Image(systemName: "location.circle.fill"), text: "My Location"),
    .init(icon: Image(systemName: "pin.circle.fill"), text: "Berlin Hauptbahnhof"),
    .init(icon: Image(systemName: "pin.circle.fill"), text: "Westend")
]

struct ContentView: View {
    var body: some View {
        DirectionList(items: sample)
        .padding()
    }
}

struct ItemBoundsKey: PreferenceKey {
    static let defaultValue: [DirectionItem.ID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [DirectionItem.ID : Anchor<CGRect>], nextValue: () -> [DirectionItem.ID : Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: from)
            p.addLine(to: to)
        }
    }
}

extension CGRect {
    subscript(unitPoint: UnitPoint) -> CGPoint {
        CGPoint(x: minX + width * unitPoint.x, y: minY + height * unitPoint.y)
    }
}

struct DirectionList: View {
    var items: [DirectionItem]

    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    item.icon
                        .frame(width: 40)
                        .anchorPreference(key: ItemBoundsKey.self, value: .bounds, transform: { [item.id: $0 ]})
                    Text(item.text)
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .overlayPreferenceValue(ItemBoundsKey.self) { bounds in
            GeometryReader { proxy in
                let pairs = Array(zip(sample, sample.dropFirst()))
                ForEach(pairs, id: \.0.id) { (item, next) in
                    if let from = bounds[item.id], let to = bounds[next.id] {
                        Line(from: proxy[from][.bottom], to: proxy[to][.top])
                            .stroke()
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
