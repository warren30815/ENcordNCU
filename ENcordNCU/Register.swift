//
//  Register.swift
//  Rec Walker
//
//  Created by BnLab on 2017/10/28.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class Register: UIViewController {

    let path = "http://140.115.152.223:7000/register/"
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordcheck: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func submit(_ sender: UIButton) {
        if name.text == "" || account.text == "" || password.text == "" || passwordcheck.text == ""{
            let alert = UIAlertController(title: "請輸入完整欄位呦", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if password.text != passwordcheck.text{
            let alert = UIAlertController(title: "請確認輸入密碼是否一致", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let body = NSMutableDictionary()
            body.setValue(name.text, forKey: "fullname")
            body.setValue(account.text, forKey: "username")
            body.setValue(password.text, forKey: "password")
            makeHTTPPostRequest(body: body)
        }
        
    }
    
    func makeHTTPPostRequest(body: NSMutableDictionary){
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest ) { (data, response, error) in
                let r = response as! HTTPURLResponse
                if r.statusCode / 100 == 4{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "此帳號已有人使用", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if r.statusCode / 100 == 5{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "很抱歉，伺服器出了些差錯", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else if r.statusCode / 100 == 2{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "註冊成功", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            task.resume()
        }catch {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
