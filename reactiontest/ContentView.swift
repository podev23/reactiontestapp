import SwiftUI

struct ContentView: View {
    @State private var round = 1
    @State private var score = 0
    @State private var isWaiting = false
    @State private var reactionTime: Double = 0.0
    @State private var startTime: Date?
    @State private var isGameOver = false
    @State private var bestRoundScore: Int = 0
    @State private var showSaveScoreAlert = false
    @State private var showNameInputSheet = false
    @State private var playerName: String = ""
    @State private var showReadyAnimation = false
    @State private var pulseEffect = 1.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Reaktionstest")
                .font(.largeTitle)
                .bold()

            if isGameOver {
                Text("Spiel beendet!")
                    .font(.title2)
                Text("Gesamtpunkte: \(score)")
                Text("Bester Rundenscore: \(bestRoundScore)")
                Button("Neues Spiel starten") {
                    restartGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .onAppear {
                    showSaveScoreAlert = true
                }
            } else {
                Text("Runde: \(round) von 5")
                Text("Punkte: \(score)")
                Text("Reaktionszeit: \(reactionTime, specifier: "%.2f") ms")
                    .font(.title2)
                    .foregroundColor(.gray)

                if showReadyAnimation {
                    Circle()
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 200 * pulseEffect, height: 200 * pulseEffect)
                        .animation(
                            Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                            value: pulseEffect
                        )
                        .onAppear {
                            self.pulseEffect = 1.2
                        }
                        .onDisappear {
                            self.pulseEffect = 1.0
                        }
                        .overlay(
                            Text("Bereit machen!")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                } else if isWaiting {
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("JETZT BERÜHREN!")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                } else {
                    Button("Starte Runde") {
                        startRound()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            Spacer()

            // Button zur Navigation zum Scoreboard
            NavigationLink(destination: ScoreboardView()) {
                Text("Scoreboard anzeigen")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showSaveScoreAlert) {
            Alert(
                title: Text("Score speichern"),
                message: Text("Möchtest du deinen besten Rundenscore (\(bestRoundScore)) speichern?"),
                primaryButton: .default(Text("Ja")) {
                    showNameInputSheet = true
                },
                secondaryButton: .cancel(Text("Nein")) {
                    restartGame()
                }
            )
        }
        .sheet(isPresented: $showNameInputSheet) {
            VStack {
                Text("Spielername eingeben")
                    .font(.headline)
                TextField("Name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Score speichern") {
                    saveScore()
                    showNameInputSheet = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .onTapGesture {
            if isWaiting {
                endRound()
            }
        }
    }

    func startRound() {
        guard round <= 5 else { return }
        isWaiting = false
        reactionTime = 0.0
        showReadyAnimation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showReadyAnimation = false
            self.isWaiting = true
            self.startTime = Date()
        }
    }

    func endRound() {
        guard isWaiting else { return }

        isWaiting = false
        if let startTime = startTime {
            reactionTime = Date().timeIntervalSince(startTime) * 1000 // Reaktionszeit in ms
            // Punkte berechnen: Je kürzer die Reaktionszeit, desto mehr Punkte
            let points = max(0, 100 - Int(reactionTime / 10))
            score += points
            bestRoundScore = max(bestRoundScore, points) // Besten Rundenscore aktualisieren
            round += 1

            print("Runde beendet: Reaktionszeit: \(reactionTime) ms, Punkte: \(points)")

            if round > 5 {
                isGameOver = true
            }
        } else {
            print("Fehler: Startzeit ist nil.")
        }
    }

    func restartGame() {
        round = 1
        score = 0
        reactionTime = 0.0
        isWaiting = false
        isGameOver = false
        bestRoundScore = 0
    }

    func saveScore() {
        PersistenceController.shared.saveScore(
            name: playerName.isEmpty ? "Unbekannt" : playerName,
            points: bestRoundScore,
            reactionTime: reactionTime
        )
        restartGame()
    }
}

