import UIKit
import Mapbox

class LocationResultCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var addressName: UILabel!
    
    @IBOutlet weak var addressAdministrative: UILabel!
    
    @IBOutlet weak var addressCountry: UILabel!
    
    var PlaceMark : CLPlacemark?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
