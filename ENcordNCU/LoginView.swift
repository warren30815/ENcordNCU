//
//  LoginView.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/23.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class LoginView: UIViewController {

    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let path = "http://140.115.152.223:7000/rest-auth/login/"
    var check: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account.text = UserDefaults.standard.object(forKey: "account") as? String ?? ""
        password.text = UserDefaults.standard.object(forKey: "password") as? String ?? ""
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: UIButton) {
        let body = NSMutableDictionary()
        body.setValue(account.text, forKey: "username")
        body.setValue(password.text, forKey: "password")
        makeHTTPPostRequest(path: path, body: body)
    }
    
    func makeHTTPPostRequest(path: String, body: NSMutableDictionary){
        
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest ) { (data, response, error) in
                guard let data = data else {
                    print("Error \(error!)")
                    return
                }
                do {
                    // Parse the JSON
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                    self.check = jsonDictionary.value(forKey: "key") as? String
                    if self.check != nil{
                        DispatchQueue.main.async{
                            let show = self.storyboard?.instantiateViewController(withIdentifier: "home")
                            self.present(show!, animated: true, completion: nil)
                    UserDefaults.standard.set(self.check, forKey: "token")
                    }
                    }else{
                        DispatchQueue.main.async {
                        let alert = UIAlertController(title: "錯誤", message: "無效的帳號或密碼", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }catch{
                    
                }
            }
            task.resume()
            } catch {
            
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(account.text, forKey: "account")
        UserDefaults.standard.set(password.text, forKey: "password")
        super.viewWillDisappear(animated)
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
