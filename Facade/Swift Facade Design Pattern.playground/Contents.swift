//: Playground - noun: a place where people can play

//
//  Swift Facade Design Pattern.playground
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
    case Inbox = "Inbox"
    case Library = "Library"
    case Temp = "tmp"
}

protocol AppDirectoryNames {
    
    func documentsDirectoryURL() -> URL
    
    func inboxDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
    
    func getURL(for directory: AppDirectories) -> URL
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
    
} // end protocol AppDirectoryNames

extension AppDirectoryNames {
    
    func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func inboxDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Inbox.rawValue) // "Inbox")
    }
    
    func libraryDirectoryURL() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
        //urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Temp.rawValue) //"tmp")
    }
    
    func getURL(for directory: AppDirectories) -> URL {
        switch directory {
        case .Documents:
            return documentsDirectoryURL()
        case .Inbox:
            return inboxDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        }
    }
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL {
        return getURL(for: directory).appendingPathComponent(name)
    }
} // end extension AppDirectoryNames

protocol AppFileStatusChecking {
    func isWritable(file at: URL) -> Bool
    
    func isReadable(file at: URL) -> Bool
    
    func exists(file at: URL) -> Bool
}

extension AppFileStatusChecking {
    func isWritable(file at: URL) -> Bool {
        if FileManager.default.isWritableFile(atPath: at.path) {
            print(at.path)
            return true
        }
        else {
            print(at.path)
            return false
        }
    }
    
    func isReadable(file at: URL) -> Bool {
        if FileManager.default.isReadableFile(atPath: at.path) {
            print(at.path)
            return true
        }
        else {
            print(at.path)
            return false
        }
    }
    
    func exists(file at: URL) -> Bool {
        if FileManager.default.fileExists(atPath: at.path) {
            return true
        }
        else {
            return false
        }
    }
} // end extension AppFileStatusChecking

protocol AppFileSystemMetaData {
    func list(directory at: URL) -> Bool
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
}

extension AppFileSystemMetaData
{
    func list(directory at: URL) -> Bool {
        let listing = try! FileManager.default.contentsOfDirectory(atPath: at.path)
        
        if listing.count > 0 {
            print("\n----------------------------")
            print("LISTING: \(at.path)")
            print("")
            for file in listing {
                print("File: \(file.debugDescription)")
            }
            print("")
            print("----------------------------\n")
            
            return true
        }
        else {
            return false
        }
    }
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any] {
        return try! FileManager.default.attributesOfItem(atPath: atFullPath.path)
    }
} // end extension AppFileSystemMetaData

protocol AppFileManipulation : AppDirectoryNames {
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
}

extension AppFileManipulation {
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool {
        let filePath = getURL(for: path).path + "/" + name
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func readFile(at path: AppDirectories, withName name: String) -> String {
        let filePath = getURL(for: path).path + "/" + name
        let fileContents = FileManager.default.contents(atPath: filePath)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        print("File created with contents: \(fileContentsAsString!)\n")
        return fileContentsAsString!
    }
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool {
        let filePath = buildFullPath(forFileName: name, inDirectory: path)
        try! FileManager.default.removeItem(at: filePath)
        print("\nFile deleted.\n")
        return true
    }
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool {
        let oldPath = getURL(for: path).appendingPathComponent(oldName)
        let newPath = getURL(for: path).appendingPathComponent(newName)
        try! FileManager.default.moveItem(at: oldPath, to: newPath)
        
        // highlights the limitations of using return values
        return true
    }
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        // warning: constant 'success' inferred to have type '()', which may be unexpected
        // let success =
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        try! FileManager.default.copyItem(at: originURL, to: destinationURL)
        return true
    }
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool {
        var newFileName = NSString(string:name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName:String =  String(newFileName)
        
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: finalFileName, inDirectory: inDirectory)
        
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        
        return true
    }
} // end extension AppFileManipulation

struct iOSAppFileSystemDirectory : AppFileManipulation, AppFileStatusChecking, AppFileSystemMetaData {
    
    let workingDirectory: AppDirectories

    init(using directory: AppDirectories) {
        self.workingDirectory = directory
    }

    func writeFile(containing text: String, withName name: String) -> Bool {
        return writeFile(containing: text, to: workingDirectory, withName: name)
    }
    
    func readFile(withName name: String) -> String {
        return readFile(at: workingDirectory, withName: name)
    }
    
    func deleteFile(withName name: String) -> Bool {
        return deleteFile(at: workingDirectory, withName: name)
    }
    
    func showAttributes(forFile named: String) -> Void {
        let fullPath = buildFullPath(forFileName: named, inDirectory: workingDirectory)
        let fileAttributes = attributes(ofFile: fullPath)
        for attribute in fileAttributes {
            print(attribute)
        }
    }
    
    func list() {
        list(directory: getURL(for: workingDirectory))
    }
    
} // end struct iOSAppFileSystemDirectory

var iOSDocumentsDirectory = iOSAppFileSystemDirectory(using: .Documents)

iOSDocumentsDirectory.writeFile(containing: "New file created.", withName: "myFile3.txt")
iOSDocumentsDirectory.list()
iOSDocumentsDirectory.readFile(withName: "myFile3.txt")
iOSDocumentsDirectory.showAttributes(forFile: "myFile3.txt")
iOSDocumentsDirectory.deleteFile(withName: "myFile3.txt")

