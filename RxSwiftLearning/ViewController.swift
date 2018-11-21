//
//  ViewController.swift
//  RxSwiftLearning
//
//  Created by mengxiangjian on 2018/9/13.
//  Copyright © 2018年 mengxiangjian. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var goButton: UIButton!
    
    let observable = Observable.of(1,2,3)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.goButton.addTarget(self, action: #selector(goSecondPage), for: .touchUpInside)
        
        observable.subscribe(onNext: { i in
            print("first:", i)
        }, onCompleted: {
            print("first completed!")
        }).disposed(by: bag)
        
        
    }
    
    @objc func goSecondPage() {
        
        observable.subscribe(onNext: { i in
            print("second:", i)
        }).disposed(by: bag)
        
        let sVC = SecondViewController()
        self.present(sVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

