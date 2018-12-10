import UIKit
import RichEditorView

class ViewController: UIViewController {
    
    
    
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let richTextEditor = JJRichTextEditor(frame:  CGRect(x:  0, y: 0, width: self.view.bounds.width, height: 88))
//        richTextEditor.doubleRows = true
        richTextEditor.editorView = editorView
        richTextEditor.htmlTextView = htmlTextView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
}

