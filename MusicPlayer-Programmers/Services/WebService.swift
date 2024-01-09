//
//  Webservice.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/03.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

class WebService {
    
    func getData<T: Decodable>(url: URL, completion: @escaping (T) -> ()) {
        
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data:Data? ,response:URLResponse? ,error:Error?) in
            
            if let error = error {
                print("1",error.localizedDescription)
            }
            
            guard let data = data else {
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(apiResponse)
            } catch {
                print("#2",error)
            }
        }
        dataTask.resume()
    }
    
    func updatePhoto(with url: URL, completion: @escaping (Data) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }
            
            completion(data)
            
        }.resume()
    }
    
    func fetchMusic() -> Observable<Music> {
        
        let urlRequest = URLRequest(url: URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")!)
        
        let response = Observable.just(urlRequest)
            .flatMap { URLSession.shared.rx.data(request: $0) }
        
        let music = response
            .map { try JSONDecoder().decode(Music.self, from: $0) }
            .catchAndReturn(Music(singer: "", album: "", title: "", duration: 0, image: "", file: "", lyrics: ""))
        
        return music
    }
    
}
