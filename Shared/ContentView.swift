//
//  ContentView.swift
//  Shared
//
//  Created by Erik Mikac on 3/3/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var score =  0
    var body: some View {
        NavigationView {
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
            List(usedWords, id: \.self) {
               
                Image(systemName: "\($0.count).circle").background(Color.green).background(Circle())
                Text($0)
            }
            }.navigationBarItems(leading: Button(action: startGame) {
                Text("Restart")}, trailing: Text("Score: \(score)"))
      
        .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            
        }
        .alert(isPresented: $showError) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }

        
    }
    func addNewWord() {
        let answer = newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word Used Already!", message: "Be more original.")
            score -= answer.count
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make up words, ya know!")
            score -= answer.count
            return
        }
        guard isReal(word: answer) && answer.count > 2 else {
            
            wordError(title: "Word must be at least three letters long.", message: "Try a bigger word.")
            score -= answer.count
            return
        }
        guard isReal(word: answer) && answer != rootWord else {
            wordError(title: "Thou shan't use that which is provided unto thee.", message: "Thou must tryest harder. :)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "This isn't a real word")
            score -= answer.count
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += answer.count
    }
 
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
      
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true

        
    }
    func startGame() {
        let stringPath = Bundle.main.path(forResource: "start", ofType: "txt")
        if let startWordsURL =
            Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                let allWords =
                startWords
                    .components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt bundle. Path: \(String(describing: stringPath))")
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
      
        }
    }
}

