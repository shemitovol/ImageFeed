import UIKit

/*extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async{
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("Server returned HTTP \(statusCode)")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
*/

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
