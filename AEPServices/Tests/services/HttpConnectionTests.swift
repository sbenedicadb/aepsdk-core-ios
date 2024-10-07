/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
*/

@testable import AEPServices
import XCTest

class HttpConnectionTests: XCTestCase {
    func testResponseHttpHeaderHappy() throws {
        // setup
        let response = HTTPURLResponse(url: URL(string: "https://someurl")!, statusCode: 200, httpVersion: nil, headerFields: ["some-key": "value"])
        let connection = HttpConnection(data: nil, response: response, error: nil)
        
        // test
        let result = connection.responseHttpHeader(forKey: "some-key")
        
        // verify
        XCTAssertEqual("value", result)
    }
    
    func testResponseHttpHeaderMisMatchedCasing() throws {
        // setup
        let response = HTTPURLResponse(url: URL(string: "https://someurl")!, statusCode: 200, httpVersion: nil, headerFields: ["Some-Key": "value"])
        let connection = HttpConnection(data: nil, response: response, error: nil)
        
        // test
        let result = connection.responseHttpHeader(forKey: "some-key")
        
        // verify
        XCTAssertEqual("value", result)
    }
    
    func testResponseHttpHeaderMisMatchedCasingTwo() throws {
        // setup
        let response = HTTPURLResponse(url: URL(string: "https://someurl")!, statusCode: 200, httpVersion: nil, headerFields: ["some-key": "value"])
        let connection = HttpConnection(data: nil, response: response, error: nil)
        
        // test
        let result = connection.responseHttpHeader(forKey: "Some-Key")
        
        // verify
        XCTAssertEqual("value", result)
    }
    
    func testResponseHttpHeaderNoMatch() throws {
        // setup
        let response = HTTPURLResponse(url: URL(string: "https://someurl")!, statusCode: 200, httpVersion: nil, headerFields: ["Some-Key": "value"])
        let connection = HttpConnection(data: nil, response: response, error: nil)
        
        // test
        let result = connection.responseHttpHeader(forKey: "something-else")
        
        // verify
        XCTAssertNil(result)
    }
}
