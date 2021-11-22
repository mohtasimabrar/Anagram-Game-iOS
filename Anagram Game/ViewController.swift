//
//  ViewController.swift
//  Anagram Game
//
//  Created by Mohtasim Abrar Samin on 22/11/21.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForInput))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForInput() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }

        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isSmall(word: lowerAnswer){
            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(answer, at: 0)

                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)

                        return
                    }
                }
            }
        }
        
        showErrorMsg(lowerAnswer)
    }
    
    func showErrorMsg(_ lowerAnswer: String) {
        var errorTitle = ""
        var errorMsg = ""
        
        if !isSmall(word: lowerAnswer){
            errorTitle = "Too short!"
            errorMsg = "Try something harder please?"
        }
        if !isPossible(word: lowerAnswer) {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMsg = "You can't spell that word from \(title)"
        }
        if !isOriginal(word: lowerAnswer) {
            errorTitle = "Word used already"
            errorMsg = "Be more original!"
        }
        if !isReal(word: lowerAnswer) {
            errorTitle = "Word not recognised"
            errorMsg = "You can't just make them up, you know!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var givenWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = givenWord.firstIndex(of: letter) {
                givenWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String)-> Bool {
        guard let givenWord = title?.lowercased() else { return false }
        
        if givenWord == word {
            return false
        }
        
        return !usedWords.contains(word)
    }
    
    func isSmall(word: String)-> Bool {
        if word.count <= 3 {
            return false
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
}
