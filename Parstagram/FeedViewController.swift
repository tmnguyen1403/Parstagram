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
    
    let query = PFQuery(className: "Post")
    query.includeKey("author")
    query.limit = 20
    
    query.findObjectsInBackground { (posts, error) in
      if posts != nil {
        self.posts = posts!
        self.tableView.reloadData()
      }
    }
  }
  
  @objc
  func onRefresh(_ refreshControl: UIRefreshControl) {
    print("onRefresh method");
    let query = PFQuery(className: "Post")
    query.includeKey("author")
    query.limit = 20
    
    query.findObjectsInBackground { (posts, error) in
      if posts != nil {
        print("onRefresh get new posts");
        self.posts = posts!
        self.tableView.reloadData()
        refreshControl.endRefreshing()
      }
    }
    
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
   

}
