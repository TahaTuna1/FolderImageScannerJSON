//
//  ContentView.swift
//  FolderImageScanner
//
//  Created by Taha Tuna on 21.06.2023.
//

import SwiftUI
import AppKit


struct ImageFiles: Codable {
    var categories: [String: [String]]
}

struct ContentView: View {
    @State private var chosenFolder = ""
    @State private var imageFiles: ImageFiles?
    @State private var jsonWritten = false
    
    var body: some View {
        VStack {
            Text("Choose Directory")
            
            Button {
                FolderChooser.choose { url, files in
                    self.chosenFolder = url?.path ?? ""
                    self.imageFiles = files
                    
                    if let chosenURL = url, let imageFiles = self.imageFiles {
                        FolderChooser.writeFilesToJson(files: imageFiles.categories, at: chosenURL)
                        jsonWritten = true
                    }
                    
                    
                    let totalImageCount = imageFiles?.categories.values.reduce(0) { $0 + $1.count } ?? 0
                    print("Total number of image files: \(totalImageCount)")
                }
            } label: {
                Text("Choose")
                    
            }
            .padding(10)
            
            Text("JSON File written to \(chosenFolder)")
                .font(.caption)
                .opacity(jsonWritten ? 1 : 0)
        }
        .padding(20)
    }
}

struct FolderChooser {
    static func choose(completion: @escaping (URL?, ImageFiles) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { response in
            if response == .OK, let chosenURL = openPanel.url {
                let files = listFiles(at: chosenURL, relativeTo: chosenURL)
                let imageFiles = ImageFiles(categories: files)
                completion(chosenURL, imageFiles)
            } else {
                completion(nil, ImageFiles(categories: [:]))
            }
        }
    }
    
    static func listFiles(at url: URL?, relativeTo rootURL: URL) -> [String: [String]] {
        guard let url = url else { return [:] }
        var files: [String: [String]] = [:]
        
        let validExtensions = ["jpg", "png", "jpeg", "gif"]
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if fileURL.hasDirectoryPath {
                    let subdirFiles = listFiles(at: fileURL, relativeTo: rootURL)
                    let directoryName = fileURL.lastPathComponent
                    
                    if let existingFiles = files[directoryName] {
                        files[directoryName] = existingFiles + subdirFiles.flatMap { $0.value }
                    } else {
                        files[directoryName] = subdirFiles.flatMap { $0.value }
                    }
                } else if validExtensions.contains(fileURL.pathExtension) {
                    let relativePath = String(fileURL.path.dropFirst(rootURL.path.count))
                    let directoryName = fileURL.deletingLastPathComponent().lastPathComponent
                    
                    if var existingFiles = files[directoryName] {
                        existingFiles.append(relativePath)
                        files[directoryName] = existingFiles
                    } else {
                        files[directoryName] = [relativePath]
                    }
                }
            }
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
        }
        
        return files
    }
    
    
    static func writeFilesToJson(files: [String: [String]], at url: URL) {
        let parentFolderName = url.lastPathComponent
        var updatedFiles = files

        for (category, paths) in updatedFiles {
            // Sort the file paths alphabetically
            let updatedPaths = paths.map { "/\(parentFolderName)\($0)" }.sorted()
            updatedFiles[category] = updatedPaths
        }

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .withoutEscapingSlashes

        do {
            let jsonData = try jsonEncoder.encode(updatedFiles)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let jsonFileURL = url.appendingPathComponent("images.json")
                try jsonString.write(to: jsonFileURL, atomically: true, encoding: .utf8)
                print("Successfully wrote JSON data to \(jsonFileURL)")

            }
        } catch {
            print("Failed to encode and write JSON data: \(error)")
        }
    }


    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
