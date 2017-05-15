//
//  RecipeStepViewController.swift
//  MyRecipe
//
//  Created by Alexandru Radu on 22/04/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit
import AVFoundation

class RecipeStepViewController: UIViewController, OEEventsObserverDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskDescriptionView: UITextView!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    @IBAction func replayAction(_ sender: Any) {
        replayTaskDescription()
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        if pauseEnabler == true{
            pauseEnabler = false
            pauseTaskDescription()
        }
        else{
            pauseEnabler = true
            pauseTaskDescription()
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        redoTask()
    }

    
    var openEarsEventsObserver = OEEventsObserver()
    let speechSynthesizer = AVSpeechSynthesizer()
    var recognitionStopped = false
    var imageToShare:UIImage!
    var pauseEnabler = false
    var taskCounter:Int = 0
    var recipeSteps:[RecipeStep] = [RecipeStep]()
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotificationCenter()
        self.openEarsEventsObserver.delegate = self
        nextButtonCustomization()
        updateTask()
        createAudioSession()
        
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        updateTask()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        readTaskDescription(enable: false)
        
    }
    
    func updateTask(){
        if taskCounter < recipeSteps.count {
            
            readTaskDescription(enable: false)
            if taskCounter == recipeSteps.count - 1 {
                nextButtonOutlet.setTitle("Finish", for: UIControlState.normal)
            }
            taskLabel.text = recipeSteps[taskCounter].task
            taskDescriptionView.text = recipeSteps[taskCounter].description
            readTaskDescription(enable: true)
            taskCounter += 1
            pauseEnabler = false
        }
        else {
            finishMessageAlert()
        }
    }
    func redoTask(){
        if taskCounter > 1 {
            
            taskCounter -= 2
            if taskCounter != recipeSteps.count - 1 {
                nextButtonOutlet.setTitle("Next step", for: UIControlState.normal)
            }
            readTaskDescription(enable: false)
            taskLabel.text = recipeSteps[taskCounter].task
            taskDescriptionView.text = recipeSteps[taskCounter].description
            readTaskDescription(enable: true)
            pauseEnabler = false
            taskCounter += 1
        }
       
    }
    
    func setNotificationCenter(){
        notificationCenter.addObserver(self, selector: #selector(appMovedToResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedFromResignActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func appMovedFromBackground(){
        
        if recognitionStopped == true{
            recognitionStopped = false
            createAudioSession()
        }
        
    }
    
    func appMovedToBackground(){
        
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        OEPocketsphinxController.sharedInstance().stopListening()
    
    }
    func appMovedFromResignActive(){
        
        if recognitionStopped == true{
            recognitionStopped = false
            createAudioSession()
        }
        
        
    }
    
    func appMovedToResignActive(){
        
        OEPocketsphinxController.sharedInstance().suspendRecognition()
        OEPocketsphinxController.sharedInstance().stopListening()
        
    }
    
    func pocketsphinxDidStopListening() {
        recognitionStopped = true
    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        //print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)" + "Asta-i tinta!")
        
        if Swift.abs(Int(recognitionScore)!) < 70000 && hypothesis!=="next"{
            nextButtonAction((Any).self)
        }
        else if Swift.abs(Int(recognitionScore)!) < 70000 && hypothesis!=="repeat"{
            replayAction((Any).self)
        }

        
    }
    
    func createAudioSession(){
        self.createVoiceRecognition()
    }
    
    func createVoiceRecognition(){
        let lmGenerator = OELanguageModelGenerator()
        let words = ["next", "repeat"] // These can be lowercase, uppercase, or mixed-case.
        let name = "NameIWantForMyLanguageModelFiles"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(err != nil) {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
            enableVoiceRecognition(path1: lmPath!, path2: dicPath!)
            
        }
    }
    
    func enableVoiceRecognition(path1:String, path2:String){
        // OELogging.startOpenEarsLogging() //Uncomment to receive full OpenEars logging in case of any unexpected results.
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
        } catch {
            print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
        }
        
        OEPocketsphinxController.sharedInstance().vadThreshold = 4.0
//        OEPocketsphinxController.sharedInstance().secondsOfSilenceToDetect = 0.5
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: path1, dictionaryAtPath: path2, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToShare = image
        }
        
        picker.dismiss(animated: true) {
            self.share()
        }
}
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.finishMessageAlert()
            }
        
    }
    
    func instantiateCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func share(){
        let activityViewController:UIActivityViewController
        // set up activity view controller
        activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks, UIActivityType.mail, UIActivityType.message, UIActivityType.saveToCameraRoll, UIActivityType.copyToPasteboard, UIActivityType.postToTencentWeibo, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToWeibo]
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                self.backToDetailView()
            }
            else {
                self.finishMessageAlert()
            }
        }
            
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func finishMessageAlert(){
        
        pauseAction((Any).self)
        let alert = UIAlertController(title: "You've just finished your dish!", message: "Congratulations!\nLet your friends know about the last recipe you've just cooked.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.instantiateCamera()
           
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.backToDetailView()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func readTaskDescription(enable:Bool){
        let speechUtterance = AVSpeechUtterance(string: taskDescriptionView.text)
        
        if enable == true{
            speechSynthesizer.speak(speechUtterance)
        }
        else {
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    func pauseTaskDescription(){
        
        if pauseEnabler == true{
            speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
        else {
            speechSynthesizer.continueSpeaking()
        }
    }
    
    func replayTaskDescription(){
        let speechUtterance = AVSpeechUtterance(string: taskDescriptionView.text)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(speechUtterance)
        pauseEnabler = false
    }
    
    func backToDetailView(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    func nextButtonCustomization(){
        nextButtonOutlet.addTextSpacing()
        nextButtonOutlet.addShadow()
    }
    
}
