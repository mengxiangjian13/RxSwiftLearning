import UIKit
import RxSwift

func example(of title:String, content:()->Void) {
    print("------------example of \(title)-----------------")
    content()
    print("---------------------- end -----------------")
}

let bag = DisposeBag()

/*
 toArray: change sequence to array
 */
example(of: "toArray") {
    Observable.of("1","2","3").toArray().subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

/*
 map: transform data
 */
example(of: "map") {
    let fomatter = NumberFormatter()
    fomatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(123,4,56).map {
        fomatter.string(from: $0) ?? ""
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
}

example(of: "map and enumerated") {
    Observable.of(1,2,3,4,5,6).enumerated().map {
        $0.index > 2 ? 2 * $0.element : $0.element
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
}

/*
 flatMap: flat observable sequences to one sequence.
 */

struct Student {
    var score : BehaviorSubject<Int>
}

example(of: "flatMap") {
    
    let meng = Student(score: BehaviorSubject(value: 90))
    let guo = Student(score: BehaviorSubject(value: 100))
    
    let student = PublishSubject<Student>()
    
    student.flatMap {
        $0.score
        }.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
    
    student.onNext(meng)
    meng.score.onNext(100)
    
    student.onNext(guo)
    guo.score.onNext(90)
}

/*
 flatMapLatest: subscribe last observale, unsubscribe previous observable.
 */
example(of: "flatMapLattest") {
    let meng = Student(score: BehaviorSubject(value: 90))
    let guo = Student(score: BehaviorSubject(value: 100))
    let student = PublishSubject<Student>()
    
    student.flatMapLatest {
        $0.score
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
    
    student.onNext(meng)
    meng.score.onNext(80)
    student.onNext(guo)
    meng.score.onNext(70) // can't print. because meng isn't the lattest observable
    guo.score.onCompleted()
    guo.score.onNext(90)
}

/*
 Challenge 1:
 */
//example(of: "Challenge 1") {
//    print("heh")
//}
example(of: "Challenge 1") {
    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    let convert: (String) -> UInt? = { value in
        if let number = UInt(value),
            number < 10 {
            return number
        }

        let keyMap: [String: UInt] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]

        let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first

        return converted
    }

    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )

        return phone
    }

    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }

    let input = Variable<String>("")

    // Add your code here
    input.asObservable().map {
        convert($0)
        }.flatMap {
            $0 == nil ? Observable.empty() : Observable.just($0!)
        }.skipWhile{
            $0 == 0
        }.take(10).toArray().subscribe(onNext: {
            print(dial(format($0)))
        }).disposed(by: disposeBag)

    input.value = ""
    input.value = "0"
    input.value = "408"

    input.value = "6"
    input.value = ""
    input.value = "0"
    input.value = "3"

    "JKL1A1B".forEach {
        input.value = "\($0)"
    }

    input.value = "9"
}



