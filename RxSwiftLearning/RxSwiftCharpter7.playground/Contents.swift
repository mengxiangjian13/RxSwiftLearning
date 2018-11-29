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


