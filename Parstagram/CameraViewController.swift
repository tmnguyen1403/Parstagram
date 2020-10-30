//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Tom Riddle on 10/20/20.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController,UINavigationControllerDelegate {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var commentField: UITextField!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  @IBAction func onSubmit(_ sender: Any) {
    
    //create Parse object
    let post = PFObject(className: "Post") //dictionary
    
    post["caption"] = commentField.text!
    post["author"] = PFUser.current()!
    
    //save image as binary object
    let imageData = imageView.image!.pngData()
    let file = PFFileObject(data: imageData!)
    
    //save image's url
    post["image"] = file
    
    post.saveInBackground { (success, error) in
      if success {
        self.dismiss(animated: true, completion: nil)
        print("saved!")
      }
      else {
        print("error!")
      }
    }
  }
  
  @IBAction func onCameraButton(_ sender: Any) {
    let picker = UIImagePickerController()
    picker.delegate = self // when you done, call me back on a function that has a photo
    picker.allowsEditing = true // allow user to edit after taking a photo
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }
    present(picker, animated: true, completion: nil)
  }
  
}

extension CameraViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = info[.editedImage] as! UIImage
    
    let size = CGSize(width: 300, height: 300)
    let scaledImage = image.af.imageAspectScaled(toFill: size)
    
    imageView.image = scaledImage
    
    dismiss(animated: true, completion: nil)
  }
}
