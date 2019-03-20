//
//  Everything.swift
//  Aion Diet
//
//  Created by Sean Hendrix on 3/13/19.
//  Copyright © 2019 Sean Hendrix. All rights reserved.
//

import UIKit

struct Profile {
    
    let name: String
    let image: UIImage
    let job: String
    
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let toVC = toVC as? DetailViewController else { return nil }
        
        toVC.loadViewIfNeeded()
        
        animator.sourceImageView = sourceCell.cellImageView
        animator.sourceNameLabel = sourceCell.nameLabel
        animator.destinationImageView = toVC.imageView
        animator.destinationNameLabel = toVC.nameLabel
        
        return animator
    }
    
    var sourceCell: TableViewCell!
    let animator = ImageTransitionAnimator()
    
    
}

class ProfileController {
    
    init() {
        let names: [String] = ["Sean", "Nick"]
        let images: [UIImage] = [#imageLiteral(resourceName: "sean"), #imageLiteral(resourceName: "nick")]
        let jobs: [String] = ["Plant Based", "Chegan (Vegan + Chicken)"]
        
        var index: Int = 0
        
        for _ in names {
            createProfile(withName: names[index], image: images[index], job: jobs[index])
            index += 1
        }
    }
    
    func createProfile(withName name: String, image: UIImage, job: String) {
        let profile = Profile(name: name, image: image, job: job)
        profiles.append(profile)
    }
    
    var profiles: [Profile] = []
}


class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = navigationControllerDelegate
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileController.profiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! TableViewCell
        
        cell.profile = profileController.profiles[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailViewController
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        detailVC.profile = profileController.profiles[indexPath.row]
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else { return }
        navigationControllerDelegate.sourceCell = cell
    }
    
    let profileController = ProfileController()
    let navigationControllerDelegate = NavigationControllerDelegate()
}

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        guard let profile = profile else { return }
        
        self.title = profile.name
        imageView.image = profile.image
        nameLabel.text = profile.name
        jobLabel.text = profile.job
    }
    
    var profile: Profile?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
}


class ImageTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to) as? DetailViewController,
            let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let toViewEndFrame = transitionContext.finalFrame(for: toVC)
        containerView.addSubview(toView)
        toView.frame = toViewEndFrame
        toView.alpha = 0.0
        
        sourceNameLabel.alpha = 0.0
        sourceImageView.alpha = 0.0
        destinationNameLabel.alpha = 0.0
        destinationImageView.alpha = 0.0
        
        let labelIntialFrame = containerView.convert(sourceNameLabel.bounds, from: sourceNameLabel)
        let animatedNameLabel = UILabel(frame: labelIntialFrame)
        animatedNameLabel.text = sourceNameLabel.text
        animatedNameLabel.font = sourceNameLabel.font
        containerView.addSubview(animatedNameLabel)
        
        let imageInitialFrame = containerView.convert(sourceImageView.bounds, from: sourceImageView)
        let animatedImageView = UIImageView(frame: imageInitialFrame)
        animatedImageView.image = sourceImageView.image
        animatedImageView.contentMode = sourceImageView.contentMode
        containerView.addSubview(animatedImageView)
        
        let duration = transitionDuration(using: transitionContext)
        toView.layoutIfNeeded()
        UIView.animate(withDuration: duration, animations: {
            animatedNameLabel.frame = containerView.convert(self.destinationNameLabel.bounds, from: self.destinationNameLabel)
            animatedImageView.frame = containerView.convert(self.destinationImageView.bounds, from: self.destinationImageView)
            toView.alpha = 1.0
        }) { (success) in
            
            self.sourceNameLabel.alpha = 1.0
            self.sourceImageView.alpha = 1.0
            self.destinationNameLabel.alpha = 1.0
            self.destinationImageView.alpha = 1.0
            animatedNameLabel.removeFromSuperview()
            animatedImageView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
    }
    
    var sourceImageView: UIImageView!
    var sourceNameLabel: UILabel!
    var destinationImageView: UIImageView!
    var destinationNameLabel: UILabel!
    
}


class TableViewCell: UITableViewCell {
    func updateViews() {
        
        guard let profile = profile else { return }
        nameLabel.text = profile.name
        cellImageView.image = profile.image
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    var profile: Profile? {
        didSet {
            updateViews()
        }
    }
    
}

