struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount: Int
    var currency: String
      
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
      
    func convert(_ currName: String) -> Money {
        let upperCase = currName.uppercased()
        guard ["USD", "GBP", "EUR", "CAN"].contains(upperCase) else {
            print("Unknown currency")
            return Money(amount: 0, currency: upperCase)
        }
        let conversionRates: [String: Double] = ["USD": 1.0, "GBP": 0.5, "EUR": 1.5, "CAN": 1.25]
        let amountUSD = Double(amount) / conversionRates[currency]!
        let convertedAmount = Int(amountUSD * conversionRates[upperCase]!)
        return Money(amount: convertedAmount, currency: upperCase)
    }

    func add(_ other: Money) -> Money {
        if self.currency == other.currency {
            return Money(amount: self.amount + other.amount, currency: self.currency)
        } else {
            let convertedSelf = self.convert(other.currency)
            return Money(amount: convertedSelf.amount + other.amount, currency: other.currency)
        }
    }
       
    func subtract(_ other: Money) -> Money {
        if self.currency == other.currency {
            return Money(amount: self.amount - other.amount, currency: self.currency)
        } else {
            let convertedOther = other.convert(self.currency)
            return Money(amount: self.amount - convertedOther.amount, currency: self.currency)
        }
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    let title: String
    var type: JobType
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hours: Int = 2000) -> Int {
        switch type {
        case .Hourly(let wage):
            return Int(wage * Double(hours))
        case .Salary(let salary):
            return Int(salary)
        }
    }
    
    func raise(byAmount: Double) {
            switch type {
            case .Hourly(let wage):
                type = .Hourly(wage + byAmount)
            case .Salary(let salary):
                type = .Salary(salary + UInt(byAmount))
            }
        }
        
    func raise(byPercent: Double) {
        switch type {
        case .Hourly(let wage):
            let raiseFactor = 1.0 + byPercent
            let newWage = wage * raiseFactor
            type = .Hourly(newWage)
        case .Salary(let salary):
            let raiseFactor = 1.0 + byPercent
            let newSalary = Double(salary) * raiseFactor
            type = .Salary(UInt(newSalary))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String
    var lastName: String
    var age: Int
    private var _job: Job?
    private var _spouse: Person?
    var job: Job? {
            get {
                return _job
            }
            set {
                if age <= 16 {
                    _job = nil
                } else {
                    _job = newValue
                }
            }
        }

        var spouse: Person? {
            get {
                return _spouse
            }
            set {
                if age <= 18 {
                    _spouse = nil
                } else {
                    _spouse = newValue
                }
            }
        }
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self._job = nil
        self._spouse = nil
    }
  
    func toString() -> String {
        let jobString = job != nil ? "\(job!)" : "nil"
        let spouseString = spouse != nil ? "\(spouse!.firstName) \(spouse!.lastName)" : "nil"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobString) spouse:\(spouseString)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person]

    init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil && spouse2.spouse == nil else {
            fatalError("Each person can only be part of one family.")
        }

        spouse1.spouse = spouse2
        spouse2.spouse = spouse1

        self.members = [spouse1, spouse2]
    }

    func haveChild(_ child: Person) -> Bool {
        guard members.contains(where: { $0.age >= 21 }) else {
            return false
        }

        members.append(child)
        return true
    }

    func householdIncome(_ hoursWorked: Int? = nil) -> Int {
        if let hoursWorked = hoursWorked {
            return members.compactMap { $0.job?.calculateIncome(hoursWorked) }.reduce(0, +)
        } else {
            return members.compactMap { $0.job?.calculateIncome(2000) }.reduce(0, +) 
        }
    }

}
