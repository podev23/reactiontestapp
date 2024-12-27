import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = "Test Player"
            newItem.points = 50
            newItem.reactionTime = 300.0
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "reactiontest")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Funktionen

    /// Speichert einen neuen Score in Core Data
    func saveScore(name: String, points: Int, reactionTime: Double) {
        let context = container.viewContext
        let newScore = Item(context: context)
        newScore.name = name
        newScore.points = Int64(points)
        newScore.reactionTime = reactionTime
        newScore.timestamp = Date()

        do {
            try context.save()
            print("Score gespeichert: \(name) - \(points) Punkte - \(reactionTime) ms")
            print("Context connected to coordinator: \(context.persistentStoreCoordinator != nil)")
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }

    /// Lädt alle Scores aus Core Data
    func fetchScores() -> [Item] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // Sortiert nach Datum

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fehler beim Laden: \(error.localizedDescription)")
            return []
        }
    }

    /// Löscht einen spezifischen Score aus Core Data
    func deleteScore(item: Item) {
        let context = container.viewContext
        context.delete(item)

        do {
            try context.save()
            print("Eintrag gelöscht: \(item)")
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }

    /// Löscht alle Scores aus Core Data
    func deleteAllScores() {
        let context = container.viewContext
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
}
