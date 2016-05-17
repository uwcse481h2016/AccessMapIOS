import UIKit

class TutorialEntryViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController!
    var pageImages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageImages = NSArray(objects: "Tutorial-1", "Tutorial-2", "Tutorial-3")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC) as! [TutorialViewController]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 80)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    @IBAction func restartAction(sender: UIButton) {
        
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC) as! [TutorialViewController]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .Reverse, animated: true, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialViewController {
        if (self.pageImages.count == 0 || (index >= self.pageImages.count)) {
            return TutorialViewController()
        }
        
        let vc: TutorialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == self.pageImages.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
