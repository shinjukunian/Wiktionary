//
//  File.swift
//  
//
//  Created by Morten Bertz on 2020/09/29.
//

import Foundation

extension NSRegularExpression{
    func stringByReplacingMatches(in string:String, template:String)->String{
        let range=NSRange(string.startIndex..<string.endIndex, in: string)
        return self.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
    }
}

extension NSTextCheckingResult{
    func substring(at idx:Int, string:String)->String{
        let nsrange=self.range(at: idx)
        let range=Range<String.Index>.init(nsrange, in: string)!
        return String(string[range])
    }
}

protocol RegexReplacing {
    func stringByReplacingMatches(in string:String)->String
}

struct ReplacementRegex: RegexReplacing {
    let regex:NSRegularExpression
    let pattern:String
    let additionalCleanUp:((String)->String)?
    
    init(regex:NSRegularExpression, pattern:String, additionalCleanUp:((String)->String)? = nil) {
        self.regex=regex
        self.pattern=pattern
        self.additionalCleanUp=additionalCleanUp
    }
    
    func stringByReplacingMatches(in string:String)->String{
        if let additional=self.additionalCleanUp{
            let retVal=self.regex.stringByReplacingMatches(in: string, template: pattern)
            return additional(retVal)
        }
        else{
            return self.regex.stringByReplacingMatches(in: string, template: pattern)
        }
        
    }
}

extension ReplacementRegex{
    static let furiganaRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\[\[([^\]]*?\|([^\]]+?))\]\]"#, options: []), pattern: "$2")
    static let furigana2Regex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\{\{((?:\p{Han}|\p{Hiragana})*?\|((?:\p{Han}|\p{Hiragana})*?)\|((?:\p{Han}|\p{Hiragana})*?)\|([^\}]*?))\}\}"#, options: []), pattern: "$2$3「$4」")
    static let furigana3Regex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\{\{((?:\p{Han}|\p{Hiragana})*?\|((?:\p{Han}|\p{Hiragana})*?)\|([^\}]*?))\}\}"#, options: []), pattern: "$2「$3」")
    static let furigana4Regex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\{\{((?:おくりがな2|ふりがな)*?\|((?:\p{Han}|\p{Hiragana})*?)\|((?:\p{Han}|\p{Hiragana})*?)\|[^\}]*?)\}\}"#, options: []), pattern: "$2「$3」")
    
    
    static let parenthesisRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\[\[([^\]]*?)\]\]"#, options: []), pattern: "$1")
    static let exponentialRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"<sup>([0-9]+)<\/sup>"#, options: []), pattern: "E$1")
    
    static let linkRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"<br\/>w:.*"#, options: []),
                                          pattern: "",
                                          additionalCleanUp: {s in
        return s.replacingOccurrences(of: "20px", with: "")
    })
    
    static let link2Regex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"<ref.*>*(.*?)(?:<\/ref>|\/>)"#, options: []), pattern: "")
    static let link3Regex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\[[^\]]+ ([^\]]+)\]"#, options: []), pattern: "$1")
    
    static let contextRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\{\{.*\}\}(.*)"#, options: []), pattern: "$1")
    
    static let subRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"<su[pb]>(.*?)<\/su[pb]>"#, options: []), pattern: "$1")
    
    static let tabunRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"(.*?)<!--.*?-->.*?<*"#, options: []), pattern: "$1$2")
    
    static let wikipediaRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\{\{wikipedia-s\|(.*?)\}\}(.*)"#, options: []), pattern: "$1$2")
    static let wikipediaLinkRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"\[*\[*Wiktionary:.*"#, options: []), pattern: "")
    static let wikiWLinkRegex=ReplacementRegex(regex: try! NSRegularExpression(pattern: #"(?:-* *|（参考：|「|→)w:.*"#, options: []), pattern: "")
    
}


