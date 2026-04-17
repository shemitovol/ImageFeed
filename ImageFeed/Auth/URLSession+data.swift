import UIKit

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let completeOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("[data(for:)]: NetworkError - \(error.localizedDescription)")
                completeOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard
                let response = response as? HTTPURLResponse
            else {
                print("[data(for:)]: InvalidRsponse")
                completeOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                print("[data(for:)]: HTTPStatusCode - \(response.statusCode)")
                completeOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                print("[data(for:)]: NoData")
                completeOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            
            completeOnMain(.success(data))
        }
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    let raw = String(data: data, encoding: .utf8) ?? ""
                    print("[objectTask]: DecodingError - \(error.localizedDescription), Data: \(raw)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask]: NetworkError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
