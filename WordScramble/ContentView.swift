//
//  ContentView.swift
//  WordScramble
//
//  Created by Sara Nicole Mikac on 2/21/20.
//  Copyright © 2020 Erik Mikac. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorShowing = false

     var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Your Word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }.navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
                .alert(isPresented: $errorShowing) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
        
        func addNewWord() {
            let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard answer.count > 0 else {
                return
            }
            guard isOriginal(word: answer) else {
                wordError(title: "Word used already!", message: "Be more original!")
                return
            }
            guard isPossible(word: answer) else {
                wordError(title: "Word not recognized", message: "You can't just make up words, ya know.")
                return
            }
            
            guard isRealWord(word: answer) else {
                wordError(title: "Word not possible", message: "That isn't a real word.")
                return
            }
            usedWords.insert(answer, at: 0)
            newWord = ""
        }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
        }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
        }
    func isPossible(word: String) -> Bool {
        var tempWord = self.rootWord.lowercased()
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
                }
            }
            return true
        }
    func isRealWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRanged = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRanged.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        errorShowing = true
    }
    
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
