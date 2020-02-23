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
    @State private var allWords = [String]()
    @State private var score = 0

     var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Your Word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)").foregroundColor(score > 0 ? .green : .red)
            }.navigationBarTitle(rootWord).navigationBarItems(trailing: Button(action: rescramble) {
                Text("Rescramble!")
            })
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
                score -= answer.count
                return
            }
            guard isPossible(word: answer) else {
                wordError(title: "Word not recognized", message: "You can't just make up words, ya know.")
                score -= answer.count
                return
            }
            
            guard isReal(word: answer) else {
                wordError(title: "Word not possible", message: "That isn't a real word.")
                score -= answer.count
                return
            }
            
            guard isLessThanThree(word: answer) else {
                wordError(title: "Word too small.", message: "Word must be more than three letters.")
                score -= answer.count
                return
            }
            
            guard isSameWord(word: answer) else {
                wordError(title: "Same word.", message: "The word must be different from the root word.")
                  score -= answer.count
                return
            }
            usedWords.insert(answer, at: 0)
            newWord = ""
            score += answer.count
        }
    
    func rescramble() {
        if let newWord = allWords.randomElement() {
            rootWord = newWord
            usedWords = []
            score = 0
        } else {
            fatalError("Word could not be rescrambled!")
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
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
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRanged = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRanged.location == NSNotFound
    }
    
    func isLessThanThree(word: String) -> Bool {
        return word.count > 3
    }
    
    func isSameWord(word: String) -> Bool {
        return word != self.rootWord
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
