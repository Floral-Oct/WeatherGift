//
//  PageVC.swift
//  WeatherGift
//
//  Created by Xiaoyu Hu on 3/18/19.
//  Copyright © 2019 Xiaoyu Hu. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController {
    
    var currentPage = 0
    var locationsArray = ["Local city", "Syndney, Australia","Accra, Ghana", "Uglich, Russia"]
    var pageControl: UIPageControl!
    var listButton : UIButton! //declare but not initialize yet
    var barButtonWidth: CGFloat = 44
    var barButtonHeight: CGFloat = 44 //core graphic numbering system
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        setViewControllers([createDetailVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    //Existing apple func viewDidAppear, but we want our own stuff in it too so we "override" it.
    override func viewDidAppear(_ animated: Bool) {
        // Call super class do everything there before we do our own stuff.
        super.viewDidAppear(animated)
        
        //Our moderation to screen
        configurePageControl()
        configureListButton()
    }
    
    /*call it in viewDidAppear b/c system hyerarchy:
    when we load a view controller, it shows up on the screen. It first loaded into memory but we cant get the size of the screen, we have to wait till the screen appear.
    configure our page once appear.*/
    
    //mark will show up on C PageVC on top bar
    //MARK: - UI Configuration Methads
    func configurePageControl(){
        //b/c apple X the safe zone is no longer rectangular. We need to minus the safeAreaInsets.bottom first.
        
        //Make symmetric, two barButtonWidth
        let pageControlHeight: CGFloat = barButtonHeight
        let pageControlWidth: CGFloat = view.frame.width - (barButtonWidth * 2)
        
        //Safe Area
        let safeHeight = view.frame.height - view.safeAreaInsets.bottom
        
        //A strcut. Get a rectangle.
        pageControl = UIPageControl(frame: CGRect(x: (view.frame.width - pageControlWidth)/2, y: safeHeight - pageControlHeight, width: pageControlWidth, height: pageControlHeight))
        pageControl.pageIndicatorTintColor = UIColor.lightGray //page dot color of frame
        pageControl.currentPageIndicatorTintColor = UIColor.black //current page dot color of frame
        pageControl.numberOfPages = locationsArray.count //# of countries
        pageControl.currentPage = currentPage
        view.addSubview(pageControl)
    }
    
    func configureListButton(){
            let safeHeight = view.frame.height - view.safeAreaInsets.bottom
        
        listButton = UIButton(frame: CGRect(x: view.frame.width - barButtonWidth, y: safeHeight - barButtonHeight, width: barButtonWidth, height: barButtonHeight))
        
        listButton.setBackgroundImage(UIImage(named: "listbutton"), for: .normal)
        listButton.setBackgroundImage(UIImage(named: "listbutton-highlighted"), for: .highlighted)
        listButton.addTarget(self, action: #selector(segueToListVC), for: .touchUpInside) //The IB action "for" when you do this event(touchUpInside) to the button will execute selector(the function)
        view.addSubview(listButton)
    }
    
    //MARK:- Segues
    //create a segueToLocationsListVC function called when listButton is clicked. Refactor to segueToListVC
    @objc func segueToListVC(){ //the selector that we put in above
        performSegue(withIdentifier: "ToListVC", sender: nil) 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListVC" { //refer segue by name
            let destination = segue.destination as! ListVC //cast it as ListVC so we can access variables in ListVC
            destination.locationsArray = locationsArray
            destination.currentPage = currentPage
            
        }
    }
    
    @IBAction func unwindFromListVC(sender: UIStoryboardSegue){
        pageControl.numberOfPages = locationsArray.count //right number of little gray dots on bottom of page
        pageControl.currentPage = currentPage
        //call createDetailVC create new pages for the current page that we are doing
        setViewControllers([createDetailVC(forPage: currentPage)], direction: .forward, animated: false, completion: nil)
    }
    
    //create a new detail View Controller for whatever page it passes in, pass back a variable that points back to the view controller which we just created. "->" means pass back
    
    //MARK: - Create View Controller for UIPageViewController
    func createDetailVC(forPage page: Int) -> DetailVC{
        //coding safty check, make sure the page we are working with is not bigger than the max siz of the array but not smaller than 0.
        currentPage = min(max(0, page), locationsArray.count-1)
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        detailVC.locationsArray = locationsArray
        detailVC.currentPage = currentPage
        return detailVC
    }
}


extension PageVC: UIPageViewControllerDataSource,
UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewController = viewController as? DetailVC {
            if currentViewController.currentPage < locationsArray.count-1{
                return createDetailVC(forPage: currentViewController.currentPage + 1)
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewController = viewController as? DetailVC{
            if currentViewController.currentPage > 0{
                return createDetailVC(forPage: currentViewController.currentPage - 1)
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        /*we are on a new page. This can have 2 pages in it if we have a spine in there. we dont so we just have to say just show me [0] because we r showing one page at a time.
        then as DetailVC b/c not just standard VC, we got separate VC detail stuff in it.*/
        if let currentViewController = pageViewController.viewControllers?[0] as?
            //Inside DetailVC we have current page variable that we r storing in it. So we want to know what page we are on now.
            DetailVC{
            pageControl.currentPage = currentViewController.currentPage
        }
    }

}
