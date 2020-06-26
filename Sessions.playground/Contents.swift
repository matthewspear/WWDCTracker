import UIKit
import PlaygroundSupport

let file = "contents.json"
let url = URL(string: "https://api2020.wwdc.io/contents.json")!

var useWeb = true

var jsonData: JSONData!
var contents: [Video]

let semaphore = DispatchSemaphore(value: 0)

if useWeb {
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: URLRequest(url: url)) { data, response, error in
        guard let data = data else { return }
        jsonData = data.decode(JSONData.self)
        semaphore.signal()
    }
    task.resume()
} else {
    jsonData = Bundle.main.decode(JSONData.self, from: file)
    semaphore.signal()
}

semaphore.wait()
contents = jsonData.contents

var outputString = "Session #; Title; Day; Length; Link; Favourite; Watched; Uninterested;\n"

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

let printFormatter = DateFormatter()
printFormatter.dateFormat = "dd"


func dateToDay(for date: String) -> String {
    let start = dateFormatter.date(from: date)!
    switch (printFormatter.string(from: start)) {
    
    case "22": return "Mon"
    case "23": return "Tues"
    case "24": return "Wed"
    case "25": return "Thu"
    case "26": return "Fri"
    default:
        return "ERR \(start)"
    }
}

for item in contents {
    if item.eventId == "wwdc2020",
       item.type != "Lab by Appointment" {
        
        outputString += "\(item.id); "
        outputString += "\(item.title); "
        
        let day = dateToDay(for: item.startTime)
        outputString += "\(day); "
        
        if let media = item.media {
            outputString += "\(media.duration / 60); "
        } else {
            outputString += "; "
        }
        
        outputString += "\(item.webPermalink); "
        
        outputString += " ; ; ;\n"
    }
}

let outputFolder = PlaygroundSupport.playgroundSharedDataDirectory
let outputURL = outputFolder.appendingPathComponent("WWDC20.csv")

do {
    try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)
    try outputString.write(toFile: outputURL.path, atomically: false, encoding: .utf8)
} catch let error {
    print(error.localizedDescription)
}

print("Open WWDC.csv at:")
print(outputURL.path.replacingOccurrences(of: " ", with: "\\ "))
