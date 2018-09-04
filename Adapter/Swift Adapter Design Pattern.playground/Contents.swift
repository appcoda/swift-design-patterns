//: Playground - noun: a place where people can play

//
//  Swift Adapter Design Pattern.playground
//
//  Created by Andrew L. Jaffee on 4/20/18.
//
/*
 
 Copyright (c) 2018 Andrew L. Jaffee, microIT Infrastructure, LLC, and iosbrain.com.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

import Foundation

enum AppDirectories : String {
    case Documents = "Documents"
    case Temp = "tmp"
}

protocol AppDirectoryNames {
    func documentsDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
}

extension AppDirectoryNames {
    func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
}

// A dedicated adapter
struct iOSFile : AppDirectoryNames {
    let fileName: URL
    var fullPathInDocuments: String {
        return documentsDirectoryURL().appendingPathComponent(fileName.absoluteString).path
    }
    var fullPathInTemporary: String {
        return tempDirectoryURL().appendingPathComponent(fileName.absoluteString).path
    }
    var documentsStringPath: String {
        return documentsDirectoryURL().path
    }
    var temporaryStringPath: String {
        return tempDirectoryURL().path
    }

    init(fileName: String) {
        self.fileName = URL(string: fileName)!
    }
}

let iOSfile = iOSFile(fileName: "myFile.txt")
iOSfile.fullPathInDocuments
iOSfile.documentsStringPath

iOSfile.fullPathInTemporary
iOSfile.temporaryStringPath

// We STILL have access to URLs
// through protocol AppDirectoryNames.
iOSfile.documentsDirectoryURL()
iOSfile.tempDirectoryURL()

// Protocol-oriented approach
protocol AppDirectoryAndFileStringPathNamesAdapter : AppDirectoryNames {
    
    var fileName: String { get }
    var workingDirectory: AppDirectories { get }

    func documentsDirectoryStringPath() -> String
    
    func tempDirectoryStringPath() -> String
    
    func fullPath() -> String
    
} // end protocol AppDirectoryAndFileStringPathAdpaterNames

extension AppDirectoryAndFileStringPathNamesAdapter {
   
    func documentsDirectoryStringPath() -> String {
        return documentsDirectoryURL().path
    }
    
    func tempDirectoryStringPath() -> String {
        return tempDirectoryURL().path
    }
    
    func fullPath() -> String {
        switch workingDirectory {
        case .Documents:
            return documentsDirectoryStringPath() + "/" + fileName
        case .Temp:
            return tempDirectoryStringPath() + "/" + fileName
        }
    }

} // end extension AppDirectoryAndFileStringPathNamesAdpater

struct AppDirectoryAndFileStringPathNames : AppDirectoryAndFileStringPathNamesAdapter {
    
    let fileName: String
    let workingDirectory: AppDirectories
    
    init(fileName: String, workingDirectory: AppDirectories) {
        self.fileName = fileName
        self.workingDirectory = workingDirectory
    }
    
} // end struct AppDirectoryAndFileStringPathNames

let appFileDocumentsDirectoryPaths = AppDirectoryAndFileStringPathNames(fileName: "myFile.txt", workingDirectory: .Documents)
appFileDocumentsDirectoryPaths.fullPath()
appFileDocumentsDirectoryPaths.documentsDirectoryStringPath()

// We STILL have access to URLs
// through protocol AppDirectoryNames.
appFileDocumentsDirectoryPaths.documentsDirectoryURL()

let appFileTemporaryDirectoryPaths = AppDirectoryAndFileStringPathNames(fileName: "tempFile.txt", workingDirectory: .Temp)
appFileTemporaryDirectoryPaths.fullPath()
appFileTemporaryDirectoryPaths.tempDirectoryStringPath()

// We STILL have access to URLs
// through protocol AppDirectoryNames.
appFileTemporaryDirectoryPaths.tempDirectoryURL()
