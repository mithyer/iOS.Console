//
//  Console.swift
//  LeBrick
//
//  Created by ray on 2017/12/15.
//  Copyright © 2017年 ray. All rights reserved.
//

import UIKit


class DiskOutput {
    
    static var curFileName: String?
    static var curFilePath: String?
    static let outputPathPrefix = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first! + "/ray/console/"

    private static func newFileHandler() -> FileHandle {
        if !FileManager.default.fileExists(atPath: outputPathPrefix) {
            try! FileManager.default.createDirectory(atPath: outputPathPrefix, withIntermediateDirectories: true, attributes: nil)
        }
        let now = Date()
        let nowString = Console.dateFormatter.string(from: now)
        curFilePath = outputPathPrefix + nowString
        curFileName = "Log_" + nowString
        if !FileManager.default.fileExists(atPath: curFilePath!) {
            let res = FileManager.default.createFile(atPath: curFilePath!, contents: Data(), attributes: [.creationDate: now, .ownerAccountName: "ray"])
            assert(res)
        }
        let handler = FileHandle(forWritingAtPath: curFilePath!)!
        return handler
    }
    
    static var fileHandler: FileHandle = DiskOutput.newFileHandler()
    
    static func resetFileHandler() {
        DispatchQueue.main.async {
            self.fileHandler.synchronizeFile()
            self.fileHandler.closeFile()
            self.fileHandler = self.newFileHandler()
        }
    }
    
    static var fileData: Data? {
        guard let path = self.curFilePath, let data = try? Data(contentsOf: URL(fileURLWithPath: path), options:Data.ReadingOptions.mappedIfSafe) else {
            return nil
        }
        return data
    }
    
    static let writeQueue = DispatchQueue(label: "ray.console.output")
    
    static func append(string: String) {
        writeQueue.async {
            let data = string.data(using: .utf8)!
            self.fileHandler.seekToEndOfFile()
            self.fileHandler.write(data)
            self.checkSizeUse()
        }
    }
    
    static let fileMaxMBSize: Double = 10
    
    static func checkSizeUse() {
        if let filePath = DiskOutput.curFilePath,
            let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
            let size = attributes[.size] as? Double,
            size/1024/1024 >= self.fileMaxMBSize {
            self.resetFileHandler()
        }
    }
}


open class Console {

    struct Log {
        init(content: String, color: UIColor, date: Date) {
            self.content = content
            self.color = color
            self.date = date
        }
        
        var content: String
        var color: UIColor
        var date: Date
        var height: Float?
    }


    static var logs: [Log] = []
    
    static let addLogQuene: DispatchQueue = DispatchQueue(label: "Ralyo.Debug.Console.addLogQueue")
    
    public static func attach(toWindow window: UIWindow) {
        self.consoleVC.window = window
    }
    
    static let consoleVC = ConsoleVC()
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        return formatter
    }()
    
    static func currentTimeStamp() -> String {
        return dateFormatter.string(from: Date())
    }
    
    public static var textAppearance: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Menlo", size: 12.0)!, .foregroundColor: UIColor.white]
    static let maxLogAmount = 10000
    
    public static func print(_ items: Any..., separator: String = " ", color: UIColor = UIColor.white, global: Bool = true) {
        
        var content = ""
        addLogQuene.async {
            for item in items[0..<items.count-1] {
                content.append("\(item)" + separator)
            }
            if let last = items.last {
                content.append("\(last)")
            }
            let now = Date()
            let log = Log(content: content, color: color, date:now)
            self.logs.append(log)
            if self.logs.count >= maxLogAmount {
                self.logs.removeSubrange(..<Int(self.logs.count/2))
            }
            DiskOutput.append(string: dateFormatter.string(from: now) + ": " + log.content + "\n")
            DispatchQueue.main.async {
                self.consoleVC.reloadData()
            }
            if global, content.count > 0 {
                Swift.print(content, separator: separator)
            }
        }
    }
    
    public static func clear() {
        addLogQuene.async {
            self.logs.removeAll()
            DiskOutput.resetFileHandler()
            DispatchQueue.main.async {
                self.consoleVC.tableView.reloadData()
            }
        }
    }
}


extension UIWindow {
    
    open override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        if let window = UIApplication.shared.delegate?.window, self == window, self == Console.consoleVC.window {
            Console.consoleVC.show()
        }
    }

}
