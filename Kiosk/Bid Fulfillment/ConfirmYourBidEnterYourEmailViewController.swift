import UIKit
import ReactiveCocoa

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidEnterYourEmailViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidEnterEmail) as! ConfirmYourBidEnterYourEmailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let emailTextSignal = emailTextField.rac_textSignal()
        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)

        confirmButton.rac_command = RACCommand(enabled: inputIsEmail) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }

            let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: self!.emailTextField.text ?? "")
            return XAppRequest(endpoint).filterStatusCode(200).doNext({ (__) -> Void in

                self?.performSegue(.ExistingArtsyUserFound)
                return
            }).doError { (error) -> Void in

                self?.performSegue(.EmailNotFoundonArtsy)
                return
            }
        }

        let unbindSignal = confirmButton.rac_command.executing.ignore(false)

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails
        RAC(nav.bidDetails.newUser, "email") <~ emailTextSignal.takeUntil(unbindSignal)

        emailTextField.returnKeySignal().subscribeNext { [weak self] (_) -> Void in
            self?.confirmButton.rac_command.execute(nil)
            return
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        self.emailTextField.becomeFirstResponder()
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {

    @IBAction func dev_emailFound(sender: AnyObject) {
        performSegue(.ExistingArtsyUserFound)
    }

    @IBAction func dev_emailNotFound(sender: AnyObject) {
        performSegue(.EmailNotFoundonArtsy)
    }

}