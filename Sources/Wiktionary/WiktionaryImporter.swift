
import Ji
import Foundation
import StringTools

public class WiktionaryImporter{
    
    public struct WiktionaryEntry: Equatable, Hashable, Codable, CustomStringConvertible{
        public let title:String
        public let meanings:[String]
        
        public var description: String{
            return "Title: \(title)\nEntries:\n\(meanings.joined(separator: "\n"))"
        }
    }
    
    var wiktionaryEntries:[String:WiktionaryEntry]=[String:WiktionaryEntry]()
    let url:URL=Bundle.module.url(forResource: "jawiktionary", withExtension: "xml")!
    
    
    let regexes: [RegexReplacing] = [ReplacementRegex.furiganaRegex,
                 ReplacementRegex.parenthesisRegex,
                 ReplacementRegex.exponentialRegex,
                 ReplacementRegex.linkRegex,
                 ReplacementRegex.furigana4Regex,
                 ReplacementRegex.furigana2Regex,
                 ReplacementRegex.furigana3Regex,
                 ReplacementRegex.wikipediaRegex,
                 ReplacementRegex.contextRegex,
                 ReplacementRegex.subRegex,
                 ReplacementRegex.link2Regex,
                 ReplacementRegex.link3Regex,
                 ReplacementRegex.tabunRegex,
                 ReplacementRegex.wikipediaLinkRegex,
                 ReplacementRegex.wikiWLinkRegex,
                 UnicodeReplacingRegex()
    
    ]
    
    
    public init(){}
    
    public func parse(stripSemantics:Bool = true){
        guard let ji=Ji(contentsOfURL: self.url, isXML: true),
              let entries=ji.rootNode?.childrenWithName("page"),
              let regex=try? NSRegularExpression(pattern: #"[= ]+意義[= ]+\n((?:[#『].+\n)+)"#, options: []),
              let headEntryRegex=try? NSRegularExpression(pattern: #"^#++([^*:][^a-z0-9]{0,3}.*)"#, options: [])
        else{abort()}
        
       
        
        for entry in entries{
            guard let titleNode=entry.firstChildWithName("title"),
                  let title=titleNode.value,
                  title.count == 1,
                  title.containsKanjiCharacters == true,
                  let contents=entry.descendantsWithName("text").first?.value,
                  contents.isEmpty == false,
                  let match=regex.firstMatch(in: contents, options: [], range: NSRange(contents.startIndex..<contents.endIndex, in: contents))
            else {continue}
            
            if title == "鰟"{
                
            }
            
        
            for idx in 1..<match.numberOfRanges{
                let description=match.substring(at: idx, string: contents)
                let lines=description.split(separator: "\n")
                let definitionEntries=lines.compactMap({entry->String? in
                    if let match=headEntryRegex.firstMatch(in: String(entry), options: [], range: NSRange(entry.startIndex..<entry.endIndex, in: entry)),
                       match.numberOfRanges > 1{
                        return match.substring(at: 1, string: String(entry))
                    }
                    else{
                        return nil
                    }
                    
                })
                
                let entries=definitionEntries.map({line->String in
                    
                    let retVal=regexes.reduce(line, {string, regex in
                        return regex.stringByReplacingMatches(in: string)
                    })
                    
                    
                    
                    return retVal.replacingOccurrences(of: "'''", with: "").trimmingCharacters(in: .whitespaces)
                }).filter({entry in
                    return entry.japaneseScriptType != .noJapaneseScript
                }).filter({entry in
                    guard stripSemantics == true else {return true}
                    return entry.contains("語義") == false
                })
                
                if entries.isEmpty == false{
                    let wiktionaryEntry=WiktionaryEntry(title: title, meanings: entries)
                    self.wiktionaryEntries[title]=wiktionaryEntry
                }
               
            }
        }
        
    }
    
    public func entry(character:String)->WiktionaryEntry?{
        return self.wiktionaryEntries[character]
    }
    
    
    func dump(to url:URL, useTable:Bool = false) throws{
        let string:String
        if useTable{
            let entries=self.wiktionaryEntries
                .values
                .sorted(by: {$0.title < $1.title})
            string=entries.reduce(String(), {dump, entry in
                return dump.appending("\(entry.title)\t\(entry.meanings.joined(separator: "\t"))\n")
            })
        }
        else{
            string=self.wiktionaryEntries
                .values
                .sorted(by: {$0.title < $1.title})
                .map({$0.description})
                .joined(separator: "\n\n")
        }
        guard let data=string.data(using: .utf8, allowLossyConversion: true) else{return}
        try data.write(to: url)
        
    }
    
}

