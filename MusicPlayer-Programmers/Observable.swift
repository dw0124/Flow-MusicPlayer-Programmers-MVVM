//
//  Observable.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/13.
//

import Foundation

class Observable<T> {
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
}
