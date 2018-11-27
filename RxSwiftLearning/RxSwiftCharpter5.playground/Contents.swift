import UIKit
import RxSwift

func example(of title:String, content:()->Void) {
    print("------------example of \(title)-----------------")
    content()
    print("---------------------- end -----------------")
}

let bag = DisposeBag()

/*
 Ignoring operator!
 */
print("Ignoring operator!")

/*
 ignoreElements. filter all .next events
 */
example(of: "ignoreElement") {
    let subject = PublishSubject<String>()
    subject.ignoreElements().subscribe {
        _ in
        print("You are out!")
    }.disposed(by: bag)
    
    // next events are ignored
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // terminated event is received.
    subject.onCompleted()
}

/*
 atElements: filter all next events except one
 */
example(of: "elementAt") {
    let subject = PublishSubject<String>()
    
    subject.elementAt(2).subscribe(onNext: {
        print("\($0)rd strike, You are out!")
    }).disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3") // 3rd .next event is received
}

/*
 filter: let the .next event which filter closure result true through.
 */

example(of: "filter") {
    Observable.of(1,2,3,4,5,6).filter {
        return $0 % 2 == 0
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
}

/*
 Skipping operator!
 */
print("Skipping operator!")

/*
 Skip: Skip first 3 elements.
 */

example(of: "Skip") {
    Observable.of(1,2,3,4,5,6).skip(3).subscribe(onNext: {
        print($0)
    }, onCompleted: {
        print("completed!")
    }).disposed(by: bag)
}

/*
 SkipWhile: skip 1 only. Because skipwhile skip elements until closure return false.
 */

example(of: "SkipWhile") {
    Observable.of(1,2,3,4).skipWhile {
        return $0 % 2 == 1
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
}

/*
 SkipUntil: Don't let element through until other obserable send event.
 */
example(of: "SkipUntil") {
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject.skipUntil(trigger).subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X")
    subject.onNext("3")
}

/*
 Taking operator! Opposite of skipping.
 */

print("Taking operator!")

/*
 Take: Let the first of the number of element get through.
 */

example(of: "Take") {
    Observable.of(1,2,3,4,5,6).take(3).subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

/*
 TakeWhile, opposite to SkipWhile.
 */

example(of: "TakeWhile") {
    Observable.of(2,2,4,4,5,6).enumerated().takeWhile {
        index, element in
        return index < 3 && element % 2 == 0
    }.map{
        return $0.element
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

/*
 TakeUntil, opposite to SkipWhile.
 */

example(of: "TakeUntil") {
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject.takeUntil(trigger).subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
    
    subject.onNext("1")
    subject.onNext("2")
    trigger.onNext("X")
    subject.onNext("3")
}

/*
 Distinct operator. Prevent duplicte element.
 */

/*
 distinctUntilChanged
 */

example(of: "DistinctUntilChanged") {
    Observable.of("A","A","B","B","A").distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "DistinctUntilChanged with condition") {
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(10,110,20,200,210,300)
        .distinctUntilChanged {
            a,b in
            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                return false
            }
            
            var containMatch = false
            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containMatch = true
                        break
                    }
                }
            }
            return containMatch
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
}


/*
 Challege1
 */

example(of: "Challenge 1") {
    
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
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
    
    let input = PublishSubject<Int>()
    
    // Add your code here
    input.skipWhile {
        $0 == 0
        }.filter {
            $0 < 10
        }.take(10).toArray().subscribe(onNext: {
            let s = phoneNumber(from: $0)
            if let r = contacts[s] {
                print("\(r) is found")
            } else {
                print("Contact not found")
            }
        }).disposed(by: bag)
    
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(2)
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}












