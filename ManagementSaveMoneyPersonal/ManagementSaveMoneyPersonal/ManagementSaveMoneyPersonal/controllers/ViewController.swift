import UIKit

class ViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var lblMonthYear: UILabel!
    @IBOutlet weak var lblExpend: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var lblNganSach: UILabel!
    @IBOutlet weak var lblConLai: UILabel!
    //white UIView
    @IBOutlet weak var budgetProgressView: UIProgressView!
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var bottomWhiteView: UIView!
    
    // Danh sách
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var emptyStateViewStackView: UIStackView!
    
    //Button
    @IBOutlet weak var btnAddTransaction: UIButton!
    
    //MARK: tao bien ngay thang hiện tại
    var selectedDay = Date()
    
    //bien luu so tien nguoi dung nhap
    var soTienNhap: Double = 0
    
    //bien luu so du
    var soDu: Double = 0
    
    //Mảng chứa tất cả giao dịch các tháng
    var allTransactions : [Transaction] = []
    
    //Mảng chứa giao dịch tháng hiện tại
    var currentMonthtransactions : [Transaction] = [] // test thử xem bằng dữ liệu fake
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateMockData()
        updateMonthYear()
        setupTableView()
        updateProgressBarUI()
    }
   
    // Kích hoạt cầu nối cho Table View
        func setupTableView() {
            transactionTableView.delegate = self
            transactionTableView.dataSource = self
            transactionTableView.tableFooterView = UIView() // Xóa gạch chân thừa
        }
    
    //MARK: Ham cap nhat chu ngay thang lable lblMonthYear
    func updateMonthYear(){
        let calendar = Calendar.current
        let monthCalendar = calendar.component(.month, from: selectedDay)
        let yearCalendar = calendar.component(.year, from: selectedDay)
        
        lblMonthYear.text = "tháng \(monthCalendar) \(yearCalendar)"
    }
    
    //MARK: Ham xu ly nut thang tiep theo
    @IBAction func btnNextMonthYear(_ sender: UIButton) {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDay){
            selectedDay = newDate
            
            //cập nhật ngày tháng khi đổi
            updateMonthYear()
            //lọc các giao dịch các tháng trong năm
            filterTransactionsForSelectedMonth()
            //tính toán số liệu các thu chi
            updateDashboardNumbers()
            //vẽ lại giao diện
            transactionTableView.reloadData()
            //update lại thanh progressBar
            updateProgressBarUI()
            
        }
    }
    //MARK: Ham xu ly nut thang trước đó
    @IBAction func btnPreviousMonthYear(_ sender: UIButton) {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDay){
            selectedDay = newDate
            
            //cập nhật ngày tháng khi đổi
            updateMonthYear()
            //lọc các giao dịch các tháng trong năm
            filterTransactionsForSelectedMonth()
            //tính toán số liệu các thu chi
            updateDashboardNumbers()
            //vẽ lại giao diện
            transactionTableView.reloadData()
            //update lại thanh progressBar
            updateProgressBarUI()
        }
    } 
        
    //MARK: tinh toan lai thanh progressBar
    func updateProgressBarUI(){
        //tinh số tiền đã tiêu
        var tienTieuHao : Double = 0
        for item in currentMonthtransactions {
            if item.type == .expense{
                tienTieuHao += item.amount
            }
            
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        //kiem tra so xem nguoi dung nhap chua
        if soTienNhap <= 0{
            lblNganSach.text = "Thiết lập ngân sách hàng tháng"
            lblConLai.isHidden = true
            lblRemaining.isHidden = true
        }else
        {
            //nguoi dung da nhap roi thay text hien lable
            lblConLai.isHidden = false
            lblRemaining.isHidden = false
            
            //chuyển số vừa nhập sang string
            let DaNhap = formatter.string(from: NSNumber(value: soTienNhap)) ?? "0"
            lblNganSach.text = "Thu nhập hàng tháng: \(DaNhap) đ"
            
            //tính số tiền còn lại
            let soTienConLai = soTienNhap - tienTieuHao
            let soTienConLaiStr = formatter.string(from: NSNumber(value: soTienConLai)) ?? "0"
            
            //kiểm tra số tiền còn lại là âm hay dương
            if(soTienConLai >= 0){
                lblRemaining.text = "+\(soTienConLaiStr)"
            }else {
                lblRemaining.text = "-\(soTienConLaiStr)"
            }
            
            //setup cho progressBar đổi màu
            let ratio = Float(tienTieuHao/soTienNhap)
            budgetProgressView.progress = min(ratio,1.0)
            
            //đổi màu cho progressBar nếu xài lố
            budgetProgressView.progressTintColor = ratio > 1.0 ? .systemRed : .systemBlue
        }
    }
    //MARK: Bắt sự kiện cho bánh răng thiết lập ngân sách
    @IBAction func setMoneyMonth(_ sender: UIButton) {
        //hiển thị hộp thoại
        let alert = UIAlertController(title: "Thu nhập hàng tháng",
                                      message: "Nhập số tiền ngân sách cho tháng này",
                                      preferredStyle: .alert)
        // Thêm ô nhập liệu (TextField) vào Alert
        alert.addTextField { textField in
            textField.placeholder = "Ví dụ: 10000000"
            textField.keyboardType = .numberPad // chỉ hiện bàn phím số
    
                    // Nếu đã có số cũ thì hiện ra luôn
            if self.soTienNhap > 0 {
                textField.text = String(format: "%.0f", self.soTienNhap)
            }
        }
        // Nút "Xác nhận"
        let confirmAction = UIAlertAction(title: "Xác nhận", style: .default) { _ in
            if let tf = alert.textFields?.first, let text = tf.text, let amount = Double(text) {
                    self.soTienNhap = amount
                self.updateProgressBarUI() // Cập nhật lại thanh Bar và Label
            }
        }
        // Nút "Hủy"
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: Tạo data giả để test
    func generateMockData() {
        // Tạo ra 1 ngày của tháng trước để test chuyển tháng
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        
        allTransactions = [
            Transaction(id: "1", title: "Lương tháng này", amount: 12000000, type: .income, date: Date()),
            Transaction(id: "2", title: "Ăn lẩu tiệc", amount: 450000, type: .expense, date: Date()),
            
            // Giao dịch này thuộc về tháng trước
            Transaction(id: "3", title: "Tiền thừa tháng trước", amount: 5000000, type: .income, date: lastMonthDate)
        ]
        filterTransactionsForSelectedMonth()
        transactionTableView.reloadData()
    }
    //MARK: hàm lọc ra các giao dịch các tháng trong năm (nếu có)
    func filterTransactionsForSelectedMonth(){
        let calander = Calendar.current
        let selectedMoth = calander.component(.month, from: selectedDay)
        let selectedYear = calander.component(.year, from: selectedDay)
        
        currentMonthtransactions = allTransactions.filter{ item in
            let itemMonth = calander.component(.month, from: item.date)
            let itemYear = calander.component(.year, from: item.date)
            return itemMonth == selectedMoth && itemYear == selectedYear
        }
    }
    //MARK: hàm cập nhật các số liệu thu chi
    func updateDashboardNumbers(){
        //đổi lại tiền tệ
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .decimal
        //bien luu tru chi tieu, thu nhap va con lai
        var incomeValue: Double = 0
        var expendValue: Double = 0
        for item in currentMonthtransactions{
            if item.type == .income{
                incomeValue += item.amount
            }
            else{
                expendValue += item.amount
            }
        }
        //doi tien te qua toString cho thu nhap va chi tieu
        let incomeString = numberFormat.string(from: NSNumber(value: incomeValue)) ?? "0"
        let expendString = numberFormat.string(from: NSNumber(value: expendValue)) ?? "0"
        
        //tinh so ra du va gán vào lblBalance
        let balanceValue = incomeValue - expendValue
        let balanceString = numberFormat.string(from: NSNumber(value: balanceValue)) ?? "0"
        lblBalance.text = balanceValue > 0 ? "+\(balanceString)" : "\(balanceString)"
        
        lblIncome.text = "+\(incomeString)"
        lblExpend.text = "-\(expendString)"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddTransactionViewController{
            
            // Nếu 'sender' gửi qua là 1 cục Transaction, thì nhét nó vào tay addVC
            if let item = sender as? Transaction{
                addVC.transactionEdit = item
            }
            addVC.onSaveTransaction = { newTransaction in
                
                //kiểm tra vị trí có trùng với id nào trong all gd ko
                if let index = self.allTransactions.firstIndex(where: {$0.id == newTransaction.id}){
                    //nếu có sửa vị trí đó = gdnew
                    self.allTransactions[index] = newTransaction
                }else{
                    //thêm giao dịch mới vào tất cả giao dịch vào cuối bảng
                    self.allTransactions.append(newTransaction)
                }
                
                //lọc các giao dịch
                self.filterTransactionsForSelectedMonth()
                
                //Cập nhật các số liệu thu chi
                self.updateDashboardNumbers()
                self.updateProgressBarUI()
                
                //vẽ lại các cells
                self.transactionTableView.reloadData()
            }
        }
    }
    @IBAction func HideAmount(_ sender: UIButton) {
        lblBalance.isHidden = true
        lblIncome.isHidden = true
        lblExpend.isHidden = true
    }
    
}

// MARK: - Xử lý hiển thị danh sách (Delegate & DataSource)
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 1. Khai báo số lượng dòng và Tự động ẩn/hiện Empty State
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isListEmpty = currentMonthtransactions.isEmpty
        
        // Logic tự động: Mảng trống thì hiện hình tờ giấy, có data thì hiện bảng
        emptyStateViewStackView.isHidden = !isListEmpty
        transactionTableView.isHidden = isListEmpty
        
        return currentMonthtransactions.count
    }
    
    // 2. Vẽ giao diện cho từng dòng (Cell)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //lấy class customTableViewCell chuyển qua tableView
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTransactionCell", for: indexPath) as? TransactionTableViewCell{
            
            //Lấy gói dữ liệu dòng tương ứng
            let item = currentMonthtransactions[indexPath.row]
            
            //đổ dữ liệu vào vào các trường custom
            cell.lblTitle.text = item.title
            
            //biến đổi dữ liệu ngày tháng
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.lblDate.text = dateFormatter.string(from: item.date)
            
            //đổi lại tiền tệ
            let numberFormat = NumberFormatter()
            numberFormat.numberStyle = .decimal
            let amountString = numberFormat.string(from: NSNumber(value: item.amount)) ?? "0"
            
            
            
            if item.type == .income{
                cell.lblAmount.text = "+ \(amountString) đ"
                cell.imgCategory.image = UIImage(systemName: "arrow.down.left.circle.fill")
            }else {
                cell.lblAmount.text = "- \(amountString) đ"
                cell.imgCategory.image = UIImage(systemName: "arrow.up.right.circle.fill")
            }
            // Tắt hiệu ứng bôi xám khi bấm vào dòng
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }

    //MARK: hàm chức năng xoá cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delected = UIContextualAction(style: .destructive, title: "Xoá"){ action, view, completion in
            //xác định dòng nào đang chọn
            let itemSelected = self.currentMonthtransactions[indexPath.row]
            //lọc và xoá hết các giao dịch trùng id
            self.allTransactions.removeAll{$0.id == itemSelected.id}
            //xoá giao dịch đó ở tháng hiện tại
            self.currentMonthtransactions.remove(at: indexPath.row)
            
            self.updateDashboardNumbers()
            self.updateProgressBarUI()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //kiểm tra nếu xoá xong mảng trống trơn thì tự động hiện ảnh trống không
            let isListEmpty = self.currentMonthtransactions.isEmpty
            self.emptyStateViewStackView.isHidden = !isListEmpty
            self.transactionTableView.isHidden = isListEmpty
            
            completion(true)
        }
        delected.image = UIImage(systemName: "trash.fill")
        delected.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delected])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = currentMonthtransactions[indexPath.row]
        performSegue(withIdentifier: "showadd", sender: selectedItem)
    }
}

