//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Tom Riddle on 10/20/20.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 

  @IBOutlet weak var tableView: UITableView!
  var refreshControl : UIRefreshControl!
  
  var posts = [PFObject]() //create an empty array of PFObject
  let LIMIT_POST:Int = 10
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    
    //refresh
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
  }
    
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    getPosts()
  }
  
  func getPosts() {
    let query = PFQuery(className: "Post")
    query.includeKey("author")
    query.limit = LIMIT_POST + self.posts.count
    
    query.findObjectsInBackground { (posts, error) in
      if posts != nil {
        print("onRefresh get new posts");
        self.posts = posts!
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
      }
      else if let error = error {
        print("Error getPoss \(error.localizedDescription)")
        self.displayError(error: error, "getPosts")
      }
    }
  }
  
  @IBAction func onLogout(_ sender: Any) {
    PFUser.logOutInBackground { (error) in
      if let error = error {
        print("Error Logout \(error.localizedDescription)")
        self.displayError(error: error, "logout")
      }
      else {
        print("logout successfully")
        NotificationCenter.default.post(name: NSNotification.Name("logout"), object: nil)
      }
    }
  }
  
  
  @objc
  func onRefresh(_ refreshControl: UIRefreshControl) {
    print("onRefresh method");
    getPosts()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    
    let post = posts[indexPath.row]
    
    let user = post["author"] as!PFUser
    cell.usernameLabel.text = user.username
    cell.captionLabel.text = post["caption"] as! String
    
    let imageFile = post["image"] as! PFFileObject
    let urlString = imageFile.url!
    let url = URL(string: urlString)!
    
    cell.photoView.af.setImage(withURL: url)
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //load more posts when reaching the end of tableView
//    if (indexPath.row + 1 == self.posts.count) {
//      getPosts()
//    }
  }
  
  func displayError(error: Error, _ performAction: String) {
    //prepare message
    let title = "Error \(performAction)"
    let message = "Something when wrong while \(performAction): \(error.localizedDescription)"
    //render error
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(OKAction)
    present(alertController, animated: true, completion: nil)
  }
}
