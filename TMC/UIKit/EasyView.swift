// Made by Lumaa

#if canImport(UIKit)
import UIKit
import SwiftUI // for view representable

/// My very first UIKit view
class FirstViewController: UIViewController {
    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.config()
    }

    func config() {
        let label: UILabel = .init()
        label.text = "This is a leftView label"
        label.textAlignment = .left

        let button: UIButton = .init()
        button.setImage(UIImage(systemName: "paperplane"), for: .highlighted)
        button.addTarget(nil, action: #selector(doSomething), for: .touchUpInside)

        self.textField = UITextField(frame: .init(x: 0, y: 0, width: 300, height: 40))
        textField.text = "This is a textfield"
        textField.placeholder = "This is a placeholder"
        textField.font = UIFont.preferredFont(forTextStyle: .title2)
        textField.textColor = UIColor.systemRed
        textField.backgroundColor = UIColor.systemBlue
        textField.leftView = label // label
        textField.rightView = button // button to send smth i guess?
    }

    @objc func doSomething(sender: UIButton) {
        Swift.debugPrint("I did something ayyyy")
    }
}

struct FirstView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let firstView: FirstViewController = .init()
        firstView.view.draw(.infinite)

        return firstView.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
