import PlaygroundSupport
import UIKit

let file = "contents.json"
let url = URL(string: "https://api2021.wwdc.io/contents.json")!
let eventID = "wwdc2023"
let outputFile = "WWDC23"

print("Hello")

var useWeb = true

var jsonData: JSONData!
var contents: [Video]

let semaphore = DispatchSemaphore(value: 0)

if useWeb {
  let session = URLSession(configuration: .default)
  let task = session.dataTask(with: URLRequest(url: url)) { data, _, _ in
    guard let data = data else { return }
    jsonData = data.decode(JSONData.self)
//    print(jsonData!)
    semaphore.signal()
  }
  task.resume()
} else {
  jsonData = Bundle.main.decode(JSONData.self, from: file)
  semaphore.signal()
}

semaphore.wait()
contents = jsonData.contents

var outputString = "Session #; Title; Date; Day; Length; Link; Favourite; Watched; Uninterested;\n"

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

let printFormatter = DateFormatter()
printFormatter.dateFormat = "dd"

let dayOfWeekFormatter = DateFormatter()
dayOfWeekFormatter.dateFormat = "E"

func dateToDayOfTheWeek(for date: String) -> String {
  if let start = dateFormatter.date(from: date) {
    return dayOfWeekFormatter.string(from: start)
  } else {
    return ""
  }
}

func dateToDay(for date: String) -> String {
  if let start = dateFormatter.date(from: date) {
    return printFormatter.string(from: start)
  } else {
    return ""
  }
}

for item in contents {
  if item.eventId == eventID,
     item.type == "Video"
//     !item.title.contains("Q&A:")
  {
    outputString += "\(item.id); "
    outputString += "\(item.title); "

    if let startTime = item.originalPublishingDate {
      print(startTime)
      let day = dateToDay(for: startTime)
      let dayOfTheWeek = dateToDayOfTheWeek(for: startTime)
      outputString += "\(day); \(dayOfTheWeek); "
    } else {
      outputString += "; ; "
    }

//    if let startTime = item.startTime {
//      outputString += "\(startTime); "
//    }

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
let outputURL = outputFolder.appendingPathComponent("\(outputFile).csv")

do {
  try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)
  try outputString.write(toFile: outputURL.path, atomically: false, encoding: .utf8)
} catch {
  print(error.localizedDescription)
}

print("Open \(outputFile).csv via:")
print("open", outputURL.path.replacingOccurrences(of: " ", with: "\\ "))
