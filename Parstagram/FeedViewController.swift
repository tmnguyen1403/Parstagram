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
  let LIMIT_POST:Int = 20
  
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
    query.includeKeys(["author", "comments", "comments.author"])
    query.limit = LIMIT_POST
    
    query.findObjectsInBackground { (posts, error) in
      if let posts = posts{
        print("onRefresh get new posts");
        self.posts = posts
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
      }
      else if let error = error {
        print("Error getPoss \(error.localizedDescription)")
        self.displayError(error: error, "getPosts")
      }
    }
    self.tableView.reloadData()
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
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let post = posts[section]
    let comments = (post["comments"] as? [PFObject]) ?? []
    
    return comments.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let post = posts[indexPath.row]
    let comments = (post["comments"] as? [PFObject]) ?? []
    
    //return a post cell
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
      let user = post["author"] as!PFUser
      cell.usernameLabel.text = user.username
      cell.captionLabel.text = post["caption"] as! String
      
      let imageFile = post["image"] as! PFFileObject
      let urlString = imageFile.url!
      let url = URL(string: urlString)!
      
      cell.photoView.af.setImage(withURL: url)
      return cell
    } else {
      //return a comment cell
      let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
      
      let comment = comments[indexPath.row - 1]
      
      cell.commentLabel.text = (comment["text"] as? String) ?? "No comment"
      
      let user = comment["author"] as! PFUser
      cell.nameLabel.text = user.username
      
      return cell
    }
  }
  
  //add comment when select post
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = posts[indexPath.row]
    
    let comment = PFObject(className: "Comments")
    comment["text"] = "This is a random comment"
    comment["post"] = post
    comment["author"] = PFUser.current()!
    
    post.add(comment, forKey: "comments")
    
    post.saveInBackground { (success, error) in
      if success {
        print("Comment saved")
      } else {
        print("Error saving comment")
      }
    }
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
