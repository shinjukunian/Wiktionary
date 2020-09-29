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
}
