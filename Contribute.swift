import Foundation

let filemgr = NSFileManager.defaultManager()
let folder = filemgr.currentDirectoryPath
let yamlDataLoc = folder + "/_data/tags.yml"

extension String {
  func replacing(mapping: [String:String]) -> String {
    return mapping.reduce(self) { acc, kv in
      let (from, to) = kv
      return acc.stringByReplacingOccurrencesOfString(from, withString: to)
    }
  }
  func removing(toRemove: [String]) -> String {
  	return self.replacing(Dictionary<String,String>(toRemove.map {($0, "")}))
  }
}

extension Dictionary { //From SwiftCheck
	init<S : SequenceType where S.Generator.Element == Element>(_ pairs : S) {
		self.init()
		var g = pairs.generate()
		while let (k, v) : (Key, Value) = g.next() {
			self[k] = v
		}
	}
}

extension Array {

	func separated() -> Array<(Element, Element)> {
		let withIndex: [(Int,Element)] = self.enumerate().map{ ($0.0 + 1, $0.1) }

		let separated: ([Element], [Element]) = withIndex.reduce(([],[])) { acc, elem in
			let (ind, value) = elem
			if ind % 2 == 0 {
				return (acc.0 + [value], acc.1)
			}
			else {
				return (acc.0, acc.1 + [value])
			}
		}

		return [(Element, Element)](Zip2Sequence(separated.1, separated.0))

	}
}



func parseCurrentTags() {
	let tagYML = try! String(contentsOfFile: yamlDataLoc)
	let parsed = Array(tagYML
										.removing(["\n", "'", "- slug","  name"])
										.componentsSeparatedByString(": ")
										.dropFirst())



}

func addPackage() {

    print("Enter package title")
    let title = readLine()!

    print("Enter package author")
    let author = readLine()!

    print("Enter package URL")
    guard let urlString = readLine(), let url = NSURL(string: urlString) else { //Not failing when it should
      exit(1)
    }

    print("Package description")
    let desc = readLine()!

    let tags = ["osx", "ios", "linux"] //Parse from tags file
    let displayTags = tags.reduce("") { acc, elem in acc + elem + "\n" }

    print("Any of the following tags?: " + displayTags + "Enter any tags with appropriate capitalization separated by spaces, as in:")
    print("OneTag SecondTag ThirdTag\n")
    print("Otherwise, just press enter")
    let packageTags = readLine()!.componentsSeparatedByString(" ")
    //Tags that weren't found: ask if they want to create them

    let components = NSCalendar.currentCalendar().components([.Day , .Month , .Year], fromDate: NSDate())
    let year = components.year
    let month = String(format: "%02d", components.month)
    let day = String(format: "%02d", components.day)

    let fileTitle = title.replacing([" " : "-"]).lowercaseString

    //Some path-appending operations are marked as unavailable, hence the manual path concat

    let mdName = "\(year)-\(month)-\(day)-" + fileTitle + ".md"

    let contents = try! String(contentsOfFile: folder + "/YYYY-MM-DD-Template.md")
    let formattedOutTags = "tags: [\(packageTags.joinWithSeparator(", "))]"

    let newWrite = contents.replacing([
      "Package Title"                     : title,
      "Package Owner"                     : author,
      "link/to/package/information/page"  : url.absoluteString,
      "tags: [ios, osx, linux]"           : formattedOutTags,
      "Short package description here. No line breaks, please. Use periods."  :  desc
    ])

    let createFilePath = folder + "/_posts/" + mdName

    //writing

    try! newWrite.writeToFile(createFilePath, atomically: true, encoding: NSUTF8StringEncoding)

}

func guidedAddTag() {
  addTag(readLine()!)
}

func addTag(tagName: String) {
	let tagsFolder = folder + "/tag"

	let templateSample = try! String(contentsOfFile: tagsFolder + "/template.html")

	let toWrite = templateSample.replacing(["TAGNAME" : tagName])
  try! toWrite.writeToFile(tagsFolder + "/" + tagName.lowercaseString + ".html", atomically: true, encoding: NSUTF8StringEncoding)


  

  let tagYML = try! String(contentsOfFile: yamlDataLoc)

  let writeYML = tagYML + "\n- slug: \(tagName.lowercaseString)\n  name: '\(tagName)'\n"
  try! writeYML.writeToFile(yamlDataLoc, atomically: true, encoding: NSUTF8StringEncoding)

}


//A rushed work-in-progress
print(
"   ____           _  ____ __      ____   __  ___\n" +
"  / ___/_      __ (_)/ __// /_    / __ \\ /  |/  /\n" +
"  \\__ \\| | /| / // // /_ / __/   / /_/ // /|_/ / \n" +
" ___/ /| |/ |/ // // __// /_ _  / ____// /  / /  \n" +
"/____/ |__/|__//_//_/   \\__/(_)/_/    /_/  /_/   \n\n" +
"A Registry\n" +
"For Packages\n" +
"For A Package Manager\n" +
"For A Programming Language\n" +
"For A Brighter Future\n\n" +
"Greetings. Enter the number of your choice:\n" +
"1 Add a package with the option to create new tags\n" +
"2 Just add new tags"
)

let selected = readLine()!
if selected == "1" {
	addPackage()
}
else if selected == "2" {
  guidedAddTag()
}
else {
	exit(1)
}
