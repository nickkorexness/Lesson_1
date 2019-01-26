import UIKit

class DebugReadingListsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var listLimitTextField: UITextField!
    @IBOutlet weak var entryLimitTextField: UITextField!
    @IBOutlet weak var addEntriesSwitch: UISwitch!
    @IBOutlet weak var createListsSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteAllListsSwitch: UISwitch!
    @IBOutlet weak var deleteAllEntriesSwitch: UISwitch!
    @IBOutlet weak var fullSyncSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let moc = SessionSingleton.sharedInstance().dataStore?.viewContext else {
            return
        }
        entryLimitTextField.returnKeyType = .done
        listLimitTextField.returnKeyType = .done
        entryLimitTextField.delegate = self
        listLimitTextField.delegate = self
        listLimitTextField.text = "\(moc.wmf_numberValue(forKey: "WMFCountOfListsToCreate")?.int64Value ?? 10)"
        entryLimitTextField.text = "\(moc.wmf_numberValue(forKey: "WMFCountOfEntriesToCreate")?.int64Value ?? 100)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func doit(_ sender: UIButton?) {
        let dataStore = SessionSingleton.sharedInstance().dataStore
        guard let readingListsController = dataStore?.readingListsController else {
            return
        }
        
        let listLimit = Int64(listLimitTextField.text ?? "10") ?? 10
        let entryLimit = Int64(entryLimitTextField.text  ?? "100") ?? 100
        
        activityIndicator.startAnimating()
        sender?.isEnabled = false
        readingListsController.debugSync(createLists: createListsSwitch.isOn, listCount: listLimit, addEntries: addEntriesSwitch.isOn, entryCount: entryLimit, deleteLists: deleteAllListsSwitch.isOn, deleteEntries: deleteAllEntriesSwitch.isOn, doFullSync: fullSyncSwitch.isOn, completion:{
            DispatchQueue.main.async {
                sender?.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
