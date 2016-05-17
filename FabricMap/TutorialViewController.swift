import UIKit

class TutorialViewController : UIViewController {
    
    @IBOutlet weak var displayImage: UIImageView!
    
    var pageIndex: Int!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayImage.image = UIImage(named: self.imageFile)
    }
}