import UIKit
import RxSwift

var str = "Hello, playground"

func example(of title:String, content:()->Void) {
    print("------------example of \(title)-----------------")
    content()
    print("---------------------- end -----------------")
}

let bag = DisposeBag()

/*
// finite event sequence
 */

let observableJust = Observable.just(1) // Observable<Int> 1
let observableArrayJust = Observable.just([1,2,3]) // Observable<[Int]> [1,2,3]
let observableOf = Observable.of(1,2,3) // Observable<Int> 1,2,3
let observableFrom = Observable.from([1,2,3]) // Observable<Int> 1,2,3
let observableRange = Observable.range(start: 4, count: 3) // Observable<Int> 4,5,6

example(of: "observableOf") {
    observableOf.subscribe(onNext: {
        print($0)
    }, onCompleted:{
        print("completed!")
    }).disposed(by: bag)
}

example(of: "observableFrom") {
    observableFrom.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

example(of: "observableRange") {
    observableRange.subscribe(onNext: {
        print($0)
    }).disposed(by: bag)
}

/*
 empty and never
 */

let observableEmpty = Observable<Int>.empty()
let observableNever = Observable<Int>.never()

example(of: "Empty") {
    observableEmpty.subscribe(onNext: {
        print($0)
    }, onCompleted: {
        print("empty observable completed!")
    }).disposed(by: bag)
}

example(of: "never") {
    observableNever.subscribe(onNext: {
        print($0)
    }, onCompleted:{
        print("never observable completed!") // never called
    }).disposed(by: bag)
}

/*
// create observable
 */
let observableCreate = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("hello")
    observer.onCompleted()
    return Disposables.create()
}

example(of: "observableCreate") {
    observableCreate.subscribe(onNext: {
        print($0)
    }, onCompleted: {
        print("completed!")
    }, onDisposed: {
        print("disposed!")
    }).disposed(by: bag)
}

/*
// leak memory (observable did not send completed/error, and did not disposed by disposebag)
// pay attention to comments
 */

let observableLeak = Observable<Int>.create { (observer) -> Disposable in
    observer.onNext(1)
//    observer.onCompleted()
    return Disposables.create()
}

example(of: "observableLeakMemory") {
    observableLeak.subscribe(onNext: {
        print($0)
    }, onCompleted: {
        
    }, onDisposed: {
        
    })
//    .disposed(by: bag)
}

/*
 observable factory. You can get different observable in different subscribe action.
 */

example(of: "deferred") {
    var flip = false
    let factory = Observable<Int>.deferred({ () -> Observable<Int> in
        flip = !flip
        if flip {
            return Observable.of(1,2,3)
        } else {
            return Observable.of(4,5,6)
        }
    })
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        }).disposed(by: bag)
        print()
    }
}

/*
 Traits:
 1. Single: single only care success or fail, success takes value, error takes a error value.(.success(value) and .error(error))
 2. Completable: completable only care completed or not, completed takes no value.(.completed and .error(error))
 3. Maybe: maybe care the three results above.(.success(value), .completed and .error(error))
 */

enum CustomError : Error {
    case error(String)
}

example(of: "Single Traits") {
    
    let s = false // modify this to look result
    
    let single = Single<String>.create(subscribe: { (single) -> Disposable in
        if s {
            single(.success("success"))
        } else {
            single(.error(CustomError.error("single trigger error")))
        }
        return Disposables.create()
    })
    
    single.subscribe(onSuccess: { (string) in
        print(string)
    }, onError: {
        error in
        if case let CustomError.error(string) = error {
            print(string)
        }
    })
}


/*
 Challenge 1. do operator。
 Observe observable subscribe flow.
 */
let someObservable = Observable.of("a","b","c")

example(of: "do operator") {
    someObservable.do(onNext: {
        print("do next: \($0)")
    }, onError: nil,
       onCompleted: {
        print("do completed!")
    }, onSubscribe: {
        print("do on subscribe")
    }, onSubscribed: {
        print("do on subscribed")
    }) {
        print("do on disposed")
        }.subscribe(onNext: {
            print($0)
        }, onError: nil,
           onCompleted: {
            print("some observable completed!")
        }) {
            print("some observable disposed!")
        }.disposed(by: bag)
}


/*
 Challenge 2. debug operator
 */

example(of: "debug operator") {
    someObservable.debug("SomeObservableIdentifier", trimOutput: false).subscribe(onNext: {
        print($0)
    }, onError: nil,
       onCompleted: {
        print("debug observable complete")
    }).disposed(by: bag)
}
