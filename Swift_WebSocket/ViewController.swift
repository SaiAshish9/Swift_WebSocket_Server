import UIKit

// StartScream, URLSession and SocketRocket

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket : URLSessionWebSocketTask?

    private let closeButton: UIButton = {
    let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
    return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
//      https://www.piesocket.com/websocket-tester
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self");
        webSocket = session.webSocketTask(with: url!);
        webSocket?.resume()
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
    }

    func ping(){
        webSocket?.sendPing {
            error in if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    @objc func close(){
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now()+1){
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"),completionHandler: {
                error in if let error = error {
                    print("Send error: \(error)")
                }
                self.send()
            })
        }
    }
    
    func receive(){
        webSocket?.receive(completionHandler: {[weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data: \(data)")
                case .string(let message):
                    print("Got String: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive Error: \(error)")
            }
            self?.receive()
        }
        )
    }
                                  
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
            print("Socket Connected Establisehd")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Socket Connection Lost: \(String(describing: reason) )")
    }
                                 
}

