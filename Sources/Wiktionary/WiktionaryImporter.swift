
import Ji
import Foundation
import StringTools

class WiktionaryImporter{
    
    public struct WiktionaryEntry: Equatable, Hashable, Codable, CustomStringConvertible{
        public let title:String
        public let meanings:[String]
        
        public var description: String{
            return "Title: \(title)\nEntries:\n\(meanings.joined(separator: "\n"))"
        }
    }
    var wiktionaryEntries:[String:WiktionaryEntry]=[String:WiktionaryEntry]()
    let url:URL=Bundle.module.url(forResource: "jawiktionary", withExtension: "xml")!
    
    public func parse(){
        guard let ji=Ji(contentsOfURL: self.url, isXML: true),
              let entries=ji.rootNode?.childrenWithName("page"),
              let regex=try? NSRegularExpression(pattern: #"\===意義===\n((?:#.+\n)+)"#, options: []),
              let headEntryRegex=try? NSRegularExpression(pattern: #"^#++([^*:][^a-z0-9]{0,3}.*)"#, options: []),
              
              let furiganaRegex=try? NSRegularExpression(pattern: #"\[\[([^\]]*?\|([^\]]+?))\]\]"#, options: []),
              let parenthesisRegex=try? NSRegularExpression(pattern: #"\[\[([^\]]*?)\]\]"#, options: []),
             
              let contextRegex=try? NSRegularExpression(pattern: #"\{\{.*\}\}(.*)"#, options: []),
              let wikipediaregex=try? NSRegularExpression(pattern: #"\{\{wikipedia-s\|(.*?)\}\}(.*)"#, options: []),
              
              let exponentialRegex=try? NSRegularExpression(pattern: #"<sup>([0-9]+)<\/sup>"#, options: []),
              let supRegex=try? NSRegularExpression(pattern: #"<su[pb]>(.*?)<\/su[pb]>"#, options: []),
              let linkRegex=try? NSRegularExpression(pattern: #"<br\/>w:.*"#, options: []),
              let link2Regex=try? NSRegularExpression(pattern: #"<ref.*>*(.*?)(?:<\/ref>|\/>)"#, options: []),
              let furiganaRegex2=try? NSRegularExpression(pattern: #"\{\{((?:\p{Han}|\p{Hiragana})*?\|((?:\p{Han}|\p{Hiragana})*?)\|((?:\p{Han}|\p{Hiragana})*?)\|([^\}]*?))\}\}"#, options: []),
              let furiganaRegex3=try? NSRegularExpression(pattern: #"\{\{((?:\p{Han}|\p{Hiragana})*?\|((?:\p{Han}|\p{Hiragana})*?)\|([^\}]*?))\}\}"#, options: []),
              let markdownLinkregex=try? NSRegularExpression(pattern: #"\[[^\]]+ ([^\]]+)\]"#, options: []),
              let furiganaRegex4=try? NSRegularExpression(pattern: #"\{\{((?:おくりがな2|ふりがな)*?\|((?:\p{Han}|\p{Hiragana})*?)\|((?:\p{Han}|\p{Hiragana})*?)\|[^\}]*?)\}\}"#, options: []),
              let tabunRegex=try? NSRegularExpression(pattern: #"(.*?)<!--.*?-->.*?<*"#, options: [])
        
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
            
            if title == "胡"{
                
            }
            
//            let regexes=[ReplacementRegex.furiganaRegex,
//                         ReplacementRegex.parenthesisRegex]
            
            
            
            
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
                    
//                    let retVal=regexes.reduce(line, {string, regex in
//                        return regex.stringByReplacingMatches(in: string)
//                    })
                    
                    
                    let furiganaStripped=furiganaRegex.stringByReplacingMatches(in: line, template: "$2")
                    
//                    let furiganaStripped=furiganaRegex.stringByReplacingMatches(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line), withTemplate: "$2")
                    let cleaned=parenthesisRegex.stringByReplacingMatches(in: furiganaStripped, options: [], range: NSRange(furiganaStripped.startIndex..<furiganaStripped.endIndex, in: furiganaStripped), withTemplate: "$1")
                    let exponentialsRemoved=exponentialRegex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned), withTemplate: "E$1")
                    let linkCleaned=linkRegex.stringByReplacingMatches(in: exponentialsRemoved, options: [], range: NSRange(exponentialsRemoved.startIndex..<exponentialsRemoved.endIndex, in: exponentialsRemoved), withTemplate: "")
                        .replacingOccurrences(of: "20px", with: "")
                    let furigana4Cleaned=furiganaRegex4.stringByReplacingMatches(in: linkCleaned, options: [], range: NSRange(linkCleaned.startIndex..<linkCleaned.endIndex, in: linkCleaned), withTemplate: "$2「$3」")
                    let furigana2Cleaned=furiganaRegex2.stringByReplacingMatches(in: furigana4Cleaned, options: [], range: NSRange(furigana4Cleaned.startIndex..<furigana4Cleaned.endIndex, in: furigana4Cleaned), withTemplate: "$2$3「$4」")
                    let furigana3Cleaned=furiganaRegex3.stringByReplacingMatches(in: furigana2Cleaned, options: [], range: NSRange(furigana2Cleaned.startIndex..<furigana2Cleaned.endIndex, in: furigana2Cleaned), withTemplate: "$2「$3」")
                    
                    let wikipediaCleaned=wikipediaregex.stringByReplacingMatches(in: furigana3Cleaned, template: "$1$2")
                    let contextStripped=contextRegex.stringByReplacingMatches(in: wikipediaCleaned, template: "$1")
                    
                    let supStripped=supRegex.stringByReplacingMatches(in: contextStripped, options: [], range: NSRange(contextStripped.startIndex..<contextStripped.endIndex, in: contextStripped), withTemplate: "$1")
                    let link2Stripped=link2Regex.stringByReplacingMatches(in: supStripped, options: [], range: NSRange(supStripped.startIndex..<supStripped.endIndex, in: supStripped), withTemplate: "")
                    let link3Stripped=markdownLinkregex.stringByReplacingMatches(in: link2Stripped, options: [], range: NSRange(link2Stripped.startIndex..<link2Stripped.endIndex, in: link2Stripped), withTemplate: "$1")
                    let tabunStripped=tabunRegex.stringByReplacingMatches(in: link3Stripped, options: [], range: NSRange(link3Stripped.startIndex..<link3Stripped.endIndex, in: link3Stripped), withTemplate: "$1$2")
                    
                    let wikiPediaLinkStripped=ReplacementRegex.wikipediaLinkRegex.stringByReplacingMatches(in: tabunStripped)
                    let wLinkSTripped=ReplacementRegex.wikiWLinkRegex.stringByReplacingMatches(in: wikiPediaLinkStripped)
                    
                    return wLinkSTripped.replacingOccurrences(of: "'''", with: "").trimmingCharacters(in: .whitespaces)
                }).filter({entry in
                    return entry.japaneseScriptType != .noJapaneseScript
                }).filter({entry in
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





extension NSTextCheckingResult{
    func substring(at idx:Int, string:String)->String{
        let nsrange=self.range(at: idx)
        let range=Range<String.Index>.init(nsrange, in: string)!
        return String(string[range])
    }
}

