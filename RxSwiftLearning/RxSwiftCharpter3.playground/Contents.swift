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
 Subject is a observable and also a observer. It can send event whenever it like, don't care if it is subscribed or not. But what event can the subscriber get depends on the subscribe time and the type of subject.
 
 All kinds of subject
 1. PublishSubject
 2. BehaviorSubject
 3. ReplaySubject
 4. Variable
 */

/*
 PublishSubject: send event to current subscribers. Don't send former event to the subscriber subscribes later. When a ternimated publishsubject is subscribed by a new subscriber, it re-emit the completed event.
 */

let publishSubject = PublishSubject<String>()

example(of: "PublishSubject") {
    publishSubject.onNext("1")
    print("subscriber1 can't receive the event 1")
    
    publishSubject.subscribe(onNext: {
        print("subscriber1 next:", $0)
    }, onCompleted: {
        print("subscriber1 completed!")
    }).disposed(by: bag)
    
    publishSubject.onNext("2")
    publishSubject.onCompleted()
    
    publishSubject.subscribe(onNext: {
        print("subscriber2 next:", $0)
    }, onCompleted: {
        print("subscriber2 completed!")
        print("subscriber2 also receive the completed event!")
    }).disposed(by: bag)
}

/*
 BehaviorSubject: similar to PublishSubject, but it emit lattest event to new subscriber. Because BehaviorSubject emit lattest enent to every new subscriber, so it must have the initial value.
 */

enum MyError : Error {
    case anError
}

func print<T:CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

let behaviorSubject = BehaviorSubject<String>(value: "initial value")

example(of: "BehaviorSubject") {
    behaviorSubject.subscribe {
        print(label: "1)", event: $0)
    }.disposed(by: bag)
    
    behaviorSubject.onNext("1")
    behaviorSubject.onError(MyError.anError)
    
    behaviorSubject.subscribe {
        print(label: "2)", event: $0)
    }.disposed(by: bag)
    
    print("subscriber2 also receive the error event")
}
