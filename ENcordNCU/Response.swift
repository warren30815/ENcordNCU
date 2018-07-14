//
//  Response.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/31.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit
import AVFoundation

class Response: UIViewController,AVAudioPlayerDelegate {

    var bartitle: String!
    var category: String!
    var practice_id: String!
    var comment_id: String!
    var token: String!
    var audio: String!
    var teacheraudio: String!
    var score: String!
    var audioplayer: AVAudioPlayer!
    var recordplayer: AVAudioPlayer!
    var audiosession = AVAudioSession.sharedInstance()
    var recordsession = AVAudioSession.sharedInstance()
    var min = 0
    var sec = 0
    var meterTimer: Timer!
    var recordmeterTimer: Timer!
    
    var practicepath = "http://140.115.152.223:7000/api/"
    var studentpath = "http://140.115.152.223:7000/api/Studentresponse/"
    
    @IBOutlet weak var responsetopic: UITextField!
    @IBOutlet weak var responsedemand: UITextView!
    @IBOutlet weak var responsecontent: UITextView!
    @IBOutlet weak var audioslider: UISlider!
    @IBOutlet weak var recordslider: UISlider!
    @IBOutlet weak var responsescore: UILabel!
    @IBOutlet weak var audiotime: UILabel!
    @IBOutlet weak var recordtime: UILabel!

    
    @IBAction func audioplay(_ sender: UIButton) {
        if audioplayer.isPlaying{
            audioplayer.pause()
            meterTimer?.invalidate()
            recordmeterTimer?.invalidate()
        }else{
            audioplayer.play()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func audioslider(_ sender: UISlider) {
        meterTimer?.invalidate()
        recordmeterTimer?.invalidate()
        audioplayer.currentTime = TimeInterval(sender.value)
        audioplayer.prepareToPlay()
        audioplayer.play()
        meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
    }
    
    @IBAction func recordplay(_ sender: UIButton) {
        if recordplayer.isPlaying{
            recordplayer.pause()
            meterTimer?.invalidate()
            recordmeterTimer?.invalidate()
        }else{
            recordplayer.play()
            recordmeterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordSlider), userInfo: nil, repeats: true)
        }
    }
 
    @IBAction func recordslider(_ sender: UISlider) {
        meterTimer?.invalidate()
        recordmeterTimer?.invalidate()
        recordplayer.currentTime = TimeInterval(sender.value)
        recordplayer.prepareToPlay()
        recordplayer.play()
        recordmeterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordSlider), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadPractice()
        downloadStudentresponse()
        responsescore.text = score
        let recordurl = URL(string: teacheraudio)
        let recorddata = NSData(contentsOf: recordurl! as URL)
        do{
            recordplayer = try AVAudioPlayer(data: recorddata! as Data)
        }catch{
            print("error")
        }
        recordplayer.delegate = self
        do{
            try recordsession.setCategory(AVAudioSessionCategoryPlayback)
            try recordsession.setActive(true)
        }
        catch{
            //error
        }
        recordslider.maximumValue = Float(recordplayer.duration)
        self.recordmeterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRecordSlider), userInfo: nil, repeats: true)
        responsescore.text = score
    }
    
    @objc func updateSlider(){
        audioslider.value = Float(audioplayer.currentTime)
        sec = Int(audioplayer.currentTime)
        min = sec / 60
        sec = sec % 60
        audiotime.text = String(format: "%02d:%02d", min,sec)
    }
    
    @objc func updateRecordSlider(){
        recordslider.value = Float(recordplayer.currentTime)
        sec = Int(recordplayer.currentTime)
        min = sec / 60
        sec = sec % 60
        recordtime.text = String(format: "%02d:%02d",min,sec)
    }
    
    func downloadPractice() {
        practicepath = "http://140.115.152.223:7000/api/"
        practicepath = practicepath + category + "/" + practice_id + "/"
        let request = NSMutableURLRequest(url: NSURL(string: practicepath)! as URL)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest ) { (data, response, error) in
            guard let data = data else {
                print("Error \(error!)")
                return
            }
            // Read the JSON
            do {
                // Parse the JSON
                let origin = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                let topic = origin.value(forKey: "topic") as! String
                let demand = origin.value(forKey: "demand") as! String
                let content = origin.value(forKey: "content") as! String
                DispatchQueue.main.async {
                    self.responsetopic.text = topic
                    self.responsedemand.text = demand
                    self.responsecontent.text = content
                }
            }catch{
                print("bad things happened")
            }
            }.resume()
        
    }
    
    func downloadStudentresponse() {
        studentpath = "http://140.115.152.223:7000/api/Studentresponse/"
        studentpath = studentpath + category + "/" + comment_id + "/"
        let request = NSMutableURLRequest(url: NSURL(string: studentpath)! as URL)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest ) { (data, response, error) in
            guard let data = data else {
                print("Error \(error!)")
                return
            }
            // Read the JSON
            do {
                // Parse the JSON
                let origin = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                
                self.audio = origin.value(forKey: "audio") as! String
                DispatchQueue.main.async {
                    let audiourl = NSURL(string: self.audio)
                    let audiodata = NSData(contentsOf: audiourl! as URL)
                    do{
                        self.audioplayer = try AVAudioPlayer(data: audiodata! as Data)
                    }catch{
                        print("error")
                    }
                    self.audioplayer.delegate = self
                    do{
                        try self.audiosession.setCategory(AVAudioSessionCategoryPlayback)
                        try self.audiosession.setActive(true)
                    }
                    catch{
                        //error
                    }
                    self.audioslider.maximumValue = Float(self.audioplayer.duration)
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                }
            }catch{
                print("bad things happened")
            }
            }.resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = bartitle
        token = "Token " + (UserDefaults.standard.object(forKey: "token") as! String)
        responsetopic.isUserInteractionEnabled = false
        responsedemand.isEditable = false
        responsecontent.isEditable = false
        // Do any additional setup after loading the view.
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == audioplayer{
        min = 0
        sec = 0
        audiotime.text = String(format: "%02d:%02d",min,sec)
        audioslider.value = 0.0
        }else if player == recordplayer{
        min = 0
        sec = 0
        recordtime.text = String(format: "%02d:%02d",min,sec)
        recordslider.value = 0.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioplayer?.stop()
        recordplayer?.stop()
        meterTimer?.invalidate()
        recordmeterTimer?.invalidate()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recordplayer = nil
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
