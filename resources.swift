import Foundation
 
// LineReader class is used to read lines from a File 

class LineReader {  
    let path: String
 
    init?(path: String) {
        self.path = path
        guard let file = fopen(path, "r") else {
            return nil
        }
        self.file = file
    }
    deinit {
        fclose(file)
    }
 
    var nextLine: String? {
        var line: UnsafeMutablePointer<CChar>?
        var linecap = 0
        defer {
            free(line)
        }
        let status = getline(&line, &linecap, file)
        guard status > 0, let unwrappedLine = line else {
            return nil
        }
        return String(cString: unwrappedLine)
    }
 
    private let file: UnsafeMutablePointer<FILE>
}
 
extension LineReader: Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine
        }
    }
}

// StringExt class is used to perform basic String tasks

class StringExt{
 
    static func idx(str: String, pos:Int)-> Character{
        let index = str.index(str.startIndex, offsetBy: pos)
        return str[index]
    }
 
    static func find(str: String, char: Character) -> Int{
        var tmp = 0
 
        for c in str{
            if c == char{
                break
            }
            tmp = tmp + 1
        }
 
        return tmp
    }
 
    static func substr(str: String, idx1: Int, idx2: Int) -> String{
        let firstIndex = str.index(str.startIndex, offsetBy: idx1)
        let secondIndex = str.index(str.startIndex, offsetBy: idx2+1)
        let range = firstIndex..<secondIndex
        return String(str[range])
    } 
 
}

//StaticAnalysis class analyzes each lines of a Swift code using Regular Expression and generates warning for methods having more than three
//parameters. 

class StaticAnalysis{
	let path:String
	init(){
		self.path = FileManager.default.currentDirectoryPath+"/main.swift"
        readL()
	}
 
	func readL(){
		guard let reader = LineReader(path: path)  else {
		    return
		}
		for line in reader {
		    let temp = line.trimmingCharacters(in: .whitespacesAndNewlines)  
		    check(line:temp)
		}
	}
 
	func check(line:String){
		let range = NSRange(location: 0, length: line.utf16.count)
		let regex = try! NSRegularExpression(pattern: "[[\\s\\w]*\\s+]?func\\s*[\\$_\\w\\(\\):,\\{\\}]+")
		if regex.firstMatch(in: line, options: [], range: range) != nil{
 
			methodInfo(line:line)
		}
	}
 
	func methodInfo(line:String){
		let bracket1 = StringExt.find(str:line,char:"(")
		let bracket2 = StringExt.find(str:line,char:")")
		let temStr = StringExt.substr(str:line, idx1:bracket1+1,idx2:bracket2-1)
		let argList = temStr.components(separatedBy:",")
 
        if(argList.count>3){
        	//var methodName = getMethodName(line:line,idx:bracket1)
        	let typeList:[String] = getMethodArgsType(args:argList)
        	var msg = typeList[0]
        	for i in 1...typeList.count-1{
        		msg = msg+","+typeList[i]
        	}
            #warning("Method contains more than three parameters.")
 
        }
	}
 
	func getMethodName(line:String, idx:Int)-> String{
		let temStr = StringExt.substr(str:line, idx1:0,idx2:idx)
		let argList = temStr.components(separatedBy:" ")
		return argList[argList.count-1].trimmingCharacters(in: .whitespacesAndNewlines)
	}
	func getMethodArgsType(args:[String]) -> Array<String> {
		var typeList:[String] = []
		for i in args{
			let list = i.components(separatedBy:":")	
			typeList.append(list[list.count-1].trimmingCharacters(in: .whitespacesAndNewlines))
		}
		return typeList
	}
 
}
 
var st = StaticAnalysis()
st.readL()