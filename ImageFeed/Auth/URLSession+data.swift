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
                completeOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard
                let response = response as? HTTPURLResponse
            else {
                completeOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                completeOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completeOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            
            completeOnMain(.success(data))
        }
        return task
    }
}
