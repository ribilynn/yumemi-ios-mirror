//
//  AsyncTestExtension.swift
//  ExampleTests
//
//  Created by Zhou Chang on 2022/05/27.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import XCTest

func asyncXCTAssertEqual<T: Equatable>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async throws {
    let value1 = try await expression1()
    let value2 = try await expression2()
    XCTAssertEqual(value1, value2, message(), file: file, line: line)
}
