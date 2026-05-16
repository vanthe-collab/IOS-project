//
//  AddTransactionViewController.swift
//  ManagementSaveMoneyPersonal
//
//  Created by vanthe on 15/05/2026.
//

import UIKit

class AddTransactionViewController: UIViewController {

    //MARK: properties
    @IBOutlet weak var segmentType: UISegmentedControl!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtNote: UITextField!
    @IBOutlet weak var lblHeader: UILabel!
    
    //tạo đường dẫn khi nhấn lưu truyền dữ liệu về cho A
    var onSaveTransaction: ((Transaction)->Void)?
    
    //tạo biến chọn danh mục nếu không chọn thì hiện là "khác"
    var selectedCategory : String = "Khác"
    
    //trường hợp sửa
    //tạo biến lưu trữ khi dashboard truyền sang
    var transactionEdit : Transaction?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryMenu()
        setupHideKeyBoard()
        //Sửa giao dịch
        if let editItem = transactionEdit{
            lblHeader.text = "Sửa giao dịch"
            txtAmount.text = String(format: "$.0f", editItem.amount)
            datePicker.date = editItem.date
            segmentType.selectedSegmentIndex = (editItem.type == .income) ? 1 : 0
            txtNote.text = editItem.title
        }else{
            //Thêm giao dịch
            //mới chuyển sang màn hình là hiện keyboard nhập liền
            txtAmount.becomeFirstResponder()
        }
        
    }
    //MARK: bắt sự kiện nút quay về
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        //đóng màn hình hiện tại
        self.dismiss(animated: true)
    }
    //MARK: bắt sự kiện nút lưu
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        var amountValue: Double = 0
        if let amountText = txtAmount.text,let amountDouble = Double(amountText){
            amountValue = amountDouble
            if amountValue < 0{
                print("Chưa nhập số tiền hợp lệ")
                return
            }
        }
        //kiểm tra người dùng chọn khoản thu hay chi(mặc định là khoản chi
        let isIncome = segmentType.selectedSegmentIndex == 1
        let type : TransactionType = isIncome ? .income : .expense
        var title = ""
        if let note = txtNote.text{
            if note.isEmpty {
                title = selectedCategory
            }else {
                title = "\(selectedCategory)/\(note)"
            }
        }
        let date = datePicker.date
        
        //kiểm tra id nếu có thì lấy id cũ để edit ko có thì tạo id mới
        let currentId = transactionEdit?.id ?? UUID().uuidString
        //Tạo 1 cuộc giao dịch
        let newTransaction = Transaction(id: currentId, title: title, amount:amountValue , type: type, date: date)
        
        //Gắn giao dịch mới cho đường dẫn
        if let save = onSaveTransaction{
            save(newTransaction)
        }
        dismiss(animated: true)
    }
    
    //MARK: Hàm tạo category menu
    func setupCategoryMenu(){
        //tạo từng dòng lựa chọn
        let actionFood = UIAction(title: "Ăn uống",image: UIImage(systemName: "fork.knife")){_ in
            self.lblCategory.text = "Ăn uống"
            self.selectedCategory = "Ăn uống"
        }
        let actionTransport = UIAction(title: "Di chuyển",image: UIImage(systemName: "car")){_ in
            self.lblCategory.text = "Di chuyển"
            self.selectedCategory = "Di chuyển"
        }
        let actionSalary = UIAction(title: "Tiền lương",image: UIImage(systemName: "banknote")){_ in
            self.lblCategory.text = "Tiền lương"
            self.selectedCategory = "Tiền Lương"
        }
        let actionOther = UIAction(title: "Khác", image: UIImage(systemName: "square.grid.2x2")) {_ in
            self.lblCategory.text = "Khác"
            self.selectedCategory = "Khác"
        }
        let menu = UIMenu(title: "Chọn Danh Mục", children: [actionFood, actionSalary, actionTransport, actionOther])
        btnCategory.menu = menu
    }
    //MARK: Ẩn bàn phím
    func setupHideKeyBoard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismisssKeyBoard))
        //nếu muốn khi nhấn button khác để tắt bàn phím và button đó ăn luôn thì mở ở dưới
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismisssKeyBoard(){
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
