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

/*
 ReplaySubject: replay lattest buffer size events to subscriber.
 Be aware of buffer size, too large buffer size could make memory warning.
 */

let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

example(of: "ReplaySubject") {
    replaySubject.onNext("1")
    replaySubject.onNext("2")
    
    replaySubject.subscribe {
        print(label: "1)", event: $0)
    }.disposed(by: bag)
    
    replaySubject.onNext("3")
    
    replaySubject.subscribe {
        print(label: "2)", event: $0)
    }.disposed(by: bag)
    
    replaySubject.onCompleted()
    
    replaySubject.subscribe {
        print(label: "3)", event: $0)
    }.disposed(by: bag)
    
    print("Every subscriber receives the completed event. Event buffer is not include the completed event.")
    
    replaySubject.dispose()
    
    replaySubject.subscribe {
        print(label: "4)", event: $0)
    }.disposed(by: bag)
    print("Replay Subject can be disposed manually.")
}

let variable = Variable<String>("initial value")

example(of: "Variable") {
    variable.asObservable().subscribe {
        print(label: "1)", event: $0)
    }.disposed(by: bag)
    
    variable.value = "1"
    
    variable.asObservable().subscribe {
        print(label: "2)", event: $0)
    }.disposed(by: bag)
    
    variable.value = "2"
    
    print("current variable's value is \(variable.value)")
    
//    variable.asObservable().onError
//    variable.asObservable().onCompleted()
    print("Variable can't emit error/completed event. Waitting for dealloc!")
}

/*
 Challenge 1: blackjack card dealer.
 */

example(of: "Challenge 1") {

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here
        let totalPoint = points(for: hand)
        if totalPoint > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to dealtHand here
    dealtHand.subscribe(onNext: {
        let handCards = cardString(for: $0)
        let totalPoints = points(for: $0)
        print("We stay in the game. Hand cards are \(handCards), total point is \(totalPoints)")
    }, onError: {
        print($0)
    }).disposed(by: disposeBag)

    deal(3)
}

example(of: "Challenge 2") {
    
    enum UserSession {
        
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession Variable of type UserSession with initial value of .loggedOut
    let variable = Variable<UserSession>(.loggedOut)
    
    
    // Subscribe to receive next events from userSession
    variable.asObservable().subscribe(onNext: {
        print("login state is: \($0)")
    }).disposed(by: disposeBag)
    
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }
        
        // Update userSession
        variable.value = .loggedIn
        completion(nil)
    }
    
    func logOut() {
        // Update userSession
        variable.value = .loggedOut
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        if variable.value == .loggedIn {
            action()
        }
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}


