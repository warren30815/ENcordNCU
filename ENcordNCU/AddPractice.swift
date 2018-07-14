//
//  AddPractice.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/20.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit
import AVFoundation

class AddPractice: UIViewController,UIPopoverPresentationControllerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate {

    var path = "http://140.115.152.223:7000/api/"
    let uploadphp = NSURL(string: "http://140.115.152.223:7001/uu.php")
    var uploadurl = "http://140.115.152.223:7001/uploads/"
    
    var token: String!
    let username = UserDefaults.standard.object(forKey: "account") as! String
    var category: String?
    var addtopic: String?
    var adddemand: String?
    var addcontent: String?
    var player: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    var min = 0
    var sec = 0
    var recordmeterTimer: Timer!
    var recordsliderTimer: Timer!
    var soundFileURL:URL!
    var currentFileName = ""
    var isrecord = 0
    
    @IBOutlet weak var categorylabel: UILabel!
    @IBOutlet weak var topic: UITextField!
    @IBOutlet weak var demand: UITextView!
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var recordbutton: UIButton!
    @IBOutlet weak var recordstop: UIButton!
    @IBOutlet weak var recordplay: UIButton!
    @IBOutlet weak var recordslider: UISlider!
    @IBOutlet weak var recordtime: UILabel!
    
    @IBOutlet weak var example_url: UITextField!
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categorylabel.text = ""
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        setSessionPlayAndRecord()
        recordstop.isEnabled = false
        recordplay.isEnabled = false
        recordslider.isEnabled = false
        // Do any additional setup after loading the view.
    }

    @IBAction func record(_ sender: UIButton) {
        recordplay.isEnabled = false
        recordslider.isEnabled = false
        submit.isEnabled = false
        
        if player != nil && player.isPlaying {
            player.stop()
        }else if recorder == nil {
            recordbutton.setTitle("⏸", for:.normal)
            recordplay.isEnabled = false
            recordstop.isEnabled = true
            recordWithPermission(true)
            return
        }else if recorder != nil && recorder.isRecording {
            recorder.pause()
            recordbutton.setTitle("⏺", for:.normal)
        }else{  //when button title is "Continue"
            recordbutton.setTitle("⏸", for:.normal)
            recordplay.isEnabled = false
            recordstop.isEnabled = true
            recordWithPermission(false)
        }
    }
    
    @IBAction func recordstop(_ sender: UIButton) {
        submit.isEnabled = true
        
        if recorder != nil{
            recorder?.stop()
            recordmeterTimer?.invalidate()
            do {
                player = try AVAudioPlayer(contentsOf: soundFileURL!)
                player.delegate = self
            }catch{
                
            }
            self.isrecord = 1
        }else if player != nil{
            player.stop()
            recordsliderTimer.invalidate()
        }
        
        recordbutton.setTitle("⏺", for: .normal)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            recordplay.isEnabled = true
            recordstop.isEnabled = false
            recordslider.isEnabled = false
            recordbutton.isEnabled = true
        } catch {
            print("could not make session inactive")
        }
    }
    
    @IBAction func recordplay(_ sender: UIButton) {
        recordslider.isEnabled = true
        recordstop.isEnabled = true
        player.prepareToPlay()
        player.volume = 1.0
        self.recordsliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordSlider), userInfo: nil, repeats: true)
        if player.isPlaying{
            player.pause()
        }else{
            player.play()
        }
    }
    
    @IBAction func recordslider(_ sender: UISlider) {
        recordslider.maximumValue = Float(player.duration)
        player.currentTime = TimeInterval(sender.value)
        player.play()
        self.recordsliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateRecordSlider(){
        if player != nil{
            recordslider.value = Float(player.currentTime)
            sec = Int(player.currentTime)
            min = sec / 60
            sec = sec % 60
            recordtime.text = String(format: "%02d:%02d",min,sec)
            
        }
    }
    
    func setupRecorder() {
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        self.currentFileName = "recording-\(format.string(from: Date()))-\(username).mp4"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            recorder = nil
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {
        
        AVAudioSession.sharedInstance().requestRecordPermission() {
            (allowed) in
            if allowed {
                
                DispatchQueue.main.async {
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    
                    self.recordmeterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                                 target:self,
                                                                 selector:#selector(self.updateAudioMeter(_:)),
                                                                 userInfo:nil,
                                                                 repeats:true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission() == .denied {
            print("permission denied")
        }
    }
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let recorder = recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                recordtime.text = s
                //recorder.updateMeters()
            }
        }
    }
    
    
    func setSessionPlayAndRecord() {
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("could not set session category")
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
        }
    }

    @IBAction func upload(_ sender: UIButton) {
        
        if category == "" || category == nil{
            let alert = UIAlertController(title: "請選擇內容分類", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let body = NSMutableDictionary()
            body.setValue(topic.text, forKey: "topic")
            body.setValue(demand.text, forKey: "demand")
            body.setValue(content.text, forKey: "content")
            if example_url.text != ""{
            body.setValue(example_url.text, forKey: "example_url")
            }
            if self.isrecord == 1{
                UploadRequest()
                uploadurl = "http://140.115.152.223:7001/uploads/"
                uploadurl = uploadurl + currentFileName
                body.setValue(uploadurl, forKey: "example_audio")
            }
            makeHTTPPostRequest(body: body)
        }
    }
    
    func UploadRequest()
    {
        
        let request = NSMutableURLRequest(url:uploadphp! as URL);
        request.httpMethod = "POST";
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let Data = NSData(contentsOf: soundFileURL)
        
        request.httpBody = createBodyWithParameters(filePathKey: "audio", DataKey: Data!, boundary: boundary) as Data
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
        }
        
        task.resume()
    }
    
    
    func createBodyWithParameters(filePathKey: String?,DataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        let filename = self.currentFileName
        let mimetype = "audio/mpeg4"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(DataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func makeHTTPPostRequest(body: NSMutableDictionary){
        path = "http://140.115.152.223:7000/api/"
        path = path + category! + "/"
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest ) { (data, response, error) in
                let r = response as! HTTPURLResponse
                if r.statusCode / 100 == 4{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "除了網址其他欄位都不能空白呦~~", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if r.statusCode / 100 == 2{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "新增練習成功", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.submit.isEnabled = false
                    }
                }
            }
            task.resume()
        }catch {
            
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,successfully flag: Bool) {
        
        recordstop.isEnabled = false
        recordplay.isEnabled = true
        recordbutton.setTitle("⏺", for:UIControlState())
        self.recorder.stop()
        self.recorder = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordbutton.isEnabled = true
        recordstop.isEnabled = false
        min = 0
        sec = 0
        recordtime.text = String(format: "%02d:%02d",min,sec)
        recordslider.value = 0.0
        recordsliderTimer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.stop()
        recordmeterTimer?.invalidate()
        recordsliderTimer?.invalidate()
        super.viewWillDisappear(animated)
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        super.prepare(for: segue, sender: sender)
        let popoverctrl = segue.destination.popoverPresentationController
        if segue.identifier == "popover"{
            if sender is UIButton{
                popoverctrl?.sourceRect = (sender as! UIButton).bounds
            }
        }
        popoverctrl?.delegate = self
    }

    @IBAction func unwind(for segue: UIStoryboardSegue){
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


