//
//  Webservice.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/03.
//

import UIKit
import Foundation

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
    
    func updatePhoto(with url: URL, completion: @escaping (UIImage) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data , let image = UIImage(data: data) else {
                return
            }
            
            completion(image)
            
        }.resume()
    }
    
}
