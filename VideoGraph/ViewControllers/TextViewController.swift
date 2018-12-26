//
//  TextViewController.swift
//  VideoGraph
//
//  Created by Admin on 17/09/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol TextViewControllerDelegate {
    func dismissTextViewCon(_ viewCon: TextViewController, _ text: String)
}

let TEXT_LIMIT: Int = 255

class TextViewController: UIViewController, UITextViewDelegate {
    var bLoadedView: Bool = false
    
    var delegate: TextViewControllerDelegate? = nil
    
    @IBOutlet weak var m_txtView: UITextView!
    @IBOutlet weak var m_lblCharactersAmount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        if (self.bLoadedView) {
            return
        }
        
        self.bLoadedView = true
        makeUserInterface()
    }
    
    func makeUserInterface() {
        self.m_txtView.delegate = self
        self.m_txtView.becomeFirstResponder()
        
        let fontObject = TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx]
        self.m_txtView.text = (fontObject.settings.text == Constants.DefaultText ? "" : fontObject.settings.text)
        
        self.updateCharacterCount()
    }
    
    func hideKeyboard() {
        self.m_txtView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        hideKeyboard()
        
        self.delegate?.dismissTextViewCon(self, "")
    }
    
    @IBAction func actionConfirm(_ sender: Any) {
        hideKeyboard()
        
        if (self.m_txtView.text.trimString().length == 0) {
            InterfaceManager.showWarningMessage("Please input something!", bBottomPos: true)
            return
        }
        
        self.delegate?.dismissTextViewCon(self, self.m_txtView.text.trimString())
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func updateCharacterCount() {
        self.m_lblCharactersAmount.text = "\((TEXT_LIMIT) - self.m_txtView.text.characters.count) characters remaining."
    }

    func textViewDidChange(_ textView: UITextView) {
        self.updateCharacterCount()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // create the updated text string
        let currentText:NSString = textView.text as! NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = ""
            self.m_lblCharactersAmount.text = "\(TEXT_LIMIT) characters remaining."
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        
        if (updatedText.length > TEXT_LIMIT) {
            let index = updatedText.index(updatedText.startIndex, offsetBy: TEXT_LIMIT)
            let limitedText = updatedText[..<index]
            self.m_txtView.text = String(limitedText)
        }
        
        self.updateCharacterCount()
        return textView.text.characters.count +  (text.characters.count - range.length) <= TEXT_LIMIT
    }
}
