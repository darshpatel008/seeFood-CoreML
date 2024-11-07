

import UIKit
import CoreML
import Vision
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
//    var classificationResults : [VNClassificationObservation] = []
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    func detect(image: CIImage) {
        // Create a configuration for the ML model
        let config = MLModelConfiguration()

        // Load the ML model with the configuration
        guard let coreMLModel = try? Inceptionv3_mlmodel_22_16_41_623(configuration: config).model else {
            fatalError("Can't load Inceptionv3 model")
        }
        
        guard let model = try? VNCoreMLModel(for: coreMLModel) else {
            fatalError("Can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
                    
            if topResult.identifier.contains("hotdog") 
            {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                }
            }
            else
            {
                DispatchQueue.main.async 
                {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do 
        {
            try handler.perform([request])
        }
        catch
        {
            print(error)
        }
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String
{
    return input.rawValue
}
