import XCTest
@testable import Wiktionary

final class WiktionaryTests: XCTestCase {
    
    func testParse() {
        let importer=WiktionaryImporter()
        importer.parse()
        ///all these are somewhat tricky and require cleanup
        XCTAssert(importer.entry(character: "手") != nil)
        XCTAssert(importer.entry(character: "矣") != nil)
        XCTAssert(importer.entry(character: "燁") != nil)
        XCTAssert(importer.entry(character: "住") != nil)
        XCTAssert(importer.entry(character: "伺") != nil)
        XCTAssert(importer.entry(character: "丼") != nil)
        XCTAssert(importer.entry(character: "胡") != nil)
        XCTAssert(importer.entry(character: "乎") != nil)
        XCTAssert(importer.entry(character: "而") != nil)
        XCTAssert(importer.entry(character: "菅") != nil)
        XCTAssertNotNil(importer.entry(character: "亜"))
        XCTAssertNotNil(importer.entry(character: "気"))
        
        XCTAssertNotNil(importer.entry(character: "鰟"))
        XCTAssertNotNil(importer.entry(character: "魡"))
        
    }
    
    func testDump() {
        let importer=WiktionaryImporter()
        importer.parse()
        XCTAssert(importer.entry(character: "手") != nil)
        let url=FileManager.default.temporaryDirectory.appendingPathComponent("Wiktionary_\(UUID().uuidString)").appendingPathExtension("txt")
        do{
            try importer.dump(to: url, useTable: true)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testUnicode(){
        let regex=try! NSRegularExpression(pattern: #"&#x([0-9A-Z]+);"#, options: [])
        let testString=#"[[&#x9B74;]]」の[[同字]]（『[[w:集韻|集韻]]』掲載）。"#
        
        let match=regex.firstMatch(in: testString, options: [], range: NSRange(testString.startIndex..<testString.endIndex, in: testString))!
        let unicode=match.substring(at: 1, string: testString)
        let codepoint=Int(unicode, radix: 16)!
        let scalar=Unicode.Scalar(codepoint)!
        let replacement=String(scalar)
        XCTAssert(replacement == "魴")
        
    }
}
