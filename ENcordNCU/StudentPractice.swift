//
//  StudentPractice.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/1.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit
import AVFoundation

class StudentPractice: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    
    var name: String!
    var demand: String!
    var content: String!
    var practice_id: Int!
    var example_audio: String!
    var example_url: String!
    var audioplayer: AVAudioPlayer!
    var player: AVAudioPlayer!
    var audiosession = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var min = 0
    var sec = 0
    var meterTimer: Timer!
    var recordmeterTimer: Timer!
    var recordsliderTimer: Timer!
    var soundFileURL:URL!
    var currentFileName = ""
    var isrecord = 0
    
    var recordpath = "http://140.115.152.223:7000/api/Studentresponse/"
    let uploadphp = NSURL(string: "http://140.115.152.223:7001/uu.php")
    var uploadurl = "http://140.115.152.223:7001/uploads/"
    
    let category = UserDefaults.standard.object(forKey: "StudentCategory") as! String
    let username = UserDefaults.standard.object(forKey: "account") as! String
    var token = UserDefaults.standard.object(forKey: "token") as! String
    
    @IBOutlet weak var hwdemand: UITextView!
    @IBOutlet weak var hwcontent: UITextView!
    
    @IBOutlet weak var audioplay: UIButton!
    @IBOutlet weak var audiostop: UIButton!
    @IBOutlet weak var audiotime: UILabel!
    @IBOutlet weak var audioslider: UISlider!
    
    @IBOutlet weak var recordbutton: UIButton!
    @IBOutlet weak var recordstop: UIButton!
    @IBOutlet weak var recordplay: UIButton!
    @IBOutlet weak var recordtime: UILabel!
    @IBOutlet weak var recordslider: UISlider!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var external_audio: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = name
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        hwdemand.text = demand
        hwcontent.text = content
        hwdemand.isEditable = false
        hwcontent.isEditable = false
        recordstop.isEnabled = false
        recordplay.isEnabled = false
        recordslider.isEnabled = false
        setSessionPlayAndRecord()
        
        if example_audio != "0"{
        let url = NSURL(string: example_audio)
        let data = NSData(contentsOf: url! as URL)
        do{
            audioplayer = try AVAudioPlayer(data: data! as Data)
        }catch{
            print("error")
        }
        audioplayer.delegate = self
        do{
            try audiosession.setCategory(AVAudioSessionCategoryPlayback)
            try audiosession.setActive(true)
        }
        catch{
            //error
        }
        audioslider.maximumValue = Float(audioplayer.duration)
        self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        }else{
            audioplay.isEnabled = false
            audiostop.isEnabled = false
            audioslider.isEnabled = false
        }
        
        if example_url == "0"{
            external_audio.isEnabled = false
        }
        // Do any additional setup after loading the view.
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
    
    @IBAction func audioplay(_ sender: UIButton) {
        if audioplayer.isPlaying{
            audioplayer.pause()
        }else{
            audioplayer.play()
        }
    }
    
    @IBAction func audiostop(_ sender: UIButton) {
        audioplayer.stop()
        audioplayer.currentTime = 0
        min = 0
        sec = 0
        audiotime.text = String(format: "%02d:%02d",min,sec)
    }
    
    @IBAction func audioslider(_ sender: UISlider) {
        audioplayer.currentTime = TimeInterval(sender.value)
        audioplayer.prepareToPlay()
        audioplayer.play()
    }
    
    @objc func updateSlider(){
        audioslider.value = Float(audioplayer.currentTime)
        sec = Int(audioplayer.currentTime)
        min = sec / 60
        sec = sec % 60
        audiotime.text = String(format: "%02d:%02d", min,sec)
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
            recorder.stop()
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
        if isrecord == 0{
            let alert = UIAlertController(title: "您還沒錄音呦~", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            UploadRequest()
            uploadurl = "http://140.115.152.223:7001/uploads/"
            uploadurl = uploadurl + currentFileName
            let body = NSMutableDictionary()
            body.setValue(practice_id, forKey: "practice_id")
            body.setValue(uploadurl, forKey: "audio")
            makeHTTPPostRequest(body: body)
            self.isrecord = 0
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
        recordpath = "http://140.115.152.223:7000/api/Studentresponse/"
        recordpath = recordpath + category + "/"
        let request = NSMutableURLRequest(url: NSURL(string: recordpath)! as URL)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest ) { (data, response, error) in
                let r = response as! HTTPURLResponse
                if r.statusCode / 100 == 2{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "上傳成功", message: nil, preferredStyle: .alert)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "external_url"{
            let vc = segue.destination as! ExternalConnection
            vc.external_url = example_url
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.stop()
        recordmeterTimer?.invalidate()
        recordsliderTimer?.invalidate()
        audioplayer?.stop()
        meterTimer?.invalidate()
        super.viewWillDisappear(animated)
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
        audioplayer = nil
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

/*extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}*/
