import SwiftUI
import CoreData

struct ScoreboardView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.points, ascending: false)],
        animation: .default
    ) private var scoreboard: FetchedResults<Item>
    @State private var alertType: AlertType? = nil

    var body: some View {
        VStack {
            Text("Scoreboard")
                .font(.largeTitle)
                .bold()

            List {
                ForEach(scoreboard, id: \.objectID) { score in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Name: \(score.name ?? "Unbekannt")")
                            Text("Punkte: \(score.points)")
                            Text("Reaktionszeit: \(score.reactionTime, specifier: "%.2f") ms")
                            Text("Datum: \(score.timestamp ?? Date(), formatter: dateFormatter)")
                        }
                        Spacer()
                        Button(action: {
                            alertType = .singleDelete(score)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }

            Button(action: {
                alertType = .deleteAll
            }) {
                Text("Alle Einträge löschen")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(item: $alertType) { alertType in
            switch alertType {
            case .singleDelete(let item):
                return Alert(
                    title: Text("Eintrag löschen"),
                    message: Text("Möchten Sie diesen Eintrag wirklich löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        deleteScore(item: item)
                    },
                    secondaryButton: .cancel(Text("Abbrechen"))
                )

            case .deleteAll:
                return Alert(
                    title: Text("Alle Einträge löschen"),
                    message: Text("Möchten Sie wirklich alle Einträge löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        deleteAllScores()
                    },
                    secondaryButton: .cancel(Text("Abbrechen"))
                )
            }
        }
    }

    // MARK: - Löschfunktionen

    func deleteScore(item: Item) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(item)

        do {
            try context.save()
            print("Eintrag gelöscht: \(item.name ?? "Unbekannt")")
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }

    func deleteAllScores() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            print("Alle Einträge wurden gelöscht.")
        } catch {
            print("Fehler beim Löschen aller Einträge: \(error.localizedDescription)")
        }
    }

    // MARK: - AlertType Enum

    enum AlertType: Identifiable {
        case singleDelete(Item)
        case deleteAll

        var id: String {
            switch self {
            case .singleDelete(let item):
                return "singleDelete-\(item.objectID)"
            case .deleteAll:
                return "deleteAll"
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

