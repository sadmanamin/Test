class Person {
    var name = ""
    var age = 0
    
    func call(name: String, phone: String, message: String, count: Int) {
      // the static analysis should issue a warning on the terminal for this method, because it has more than 3 parameters
    }
    
    func reset() {
        name = ""
        age = 0
    }
}

StaticAnalysis()