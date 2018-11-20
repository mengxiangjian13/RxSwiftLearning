//
//  SecondViewController.swift
//  RxSwiftLearning
//
//  Created by mengxiangjian on 2018/9/13.
//  Copyright © 2018年 mengxiangjian. All rights reserved.
//

import UIKit
import RxSwift

class SecondViewController: UIViewController {
    
    var disposeBag : DisposeBag
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.disposeBag = DisposeBag()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellow
        
        self.addBackButton()
        
        // Do any additional setup after loading the view.
        Observable<Int>.create { observer -> Disposable in
            observer.onNext(1)
            observer.onCompleted() // call onComleted means Observale object disposed, so dispose block calls.
            return Disposables.create()
            }.map({
                $0 + 1 // map can change the element
            }).subscribe(onNext: { i in
                print(i)
            }, onError: nil, onCompleted: {
                print("complete!")
            }) {
                print("disposed")
        }.disposed(by: self.disposeBag)
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//        button.backgroundColor = UIColor.red
        button.center = self.view.center
        button.setTitle("back", for: .normal)
        button.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func back(_ sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
