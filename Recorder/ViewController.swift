
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    let recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var player : AVAudioPlayer!
    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    var isRecording = false
    var arraySound: [String] = UserDefaults.standard.array(forKey: "Record") as? [String] ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(arraySound)
    }
    
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(recordButton)
        updateUI()
    }
    
    
    // MARK: - Configure UI
    func updateUI(){
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let recordButtonHeightConstraint = recordButton.heightAnchor.constraint(equalToConstant: 50)
        recordButtonHeightConstraint.isActive = true
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor, multiplier: 1.0).isActive = true
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
        recordButton.layer.cornerRadius = recordButtonHeightConstraint.constant/2
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.layer.borderWidth = 5.0
        recordButton.imageEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        recordButton.addTarget(self, action: #selector(record(sender:)), for: .touchUpInside)
    }
}


//MARK: - Audio
extension ViewController {
    @objc func record(sender: UIButton) {
        if isRecording {
            finishRecording()
        } else {
            startRecording()
        }
    }
    
    func getAudioFileUrl() -> URL{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = formatter.string(from: Date())
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileName = date
        let audioUrl = docsDirect.appendingPathComponent(fileName)
        arraySound.insert(fileName, at: 0)
        UserDefaults.standard.set(arraySound, forKey: "Record")
        UserDefaults.standard.synchronize()
        return audioUrl
    }
}

//MARK: - TableView DataSource and Delegate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySound.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayTableViewCell", for: indexPath) as? PlayTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: arraySound[indexPath.row])
        cell.audio = arraySound[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            arraySound.remove(at: indexPath.row)
            UserDefaults.standard.set(arraySound, forKey: "Record")
            UserDefaults.standard.synchronize()
            self.tableView.reloadData()
        }
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


//MARK: - Methods of working with sound
extension ViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func startRecording() {
        // Create the session
        let session = AVAudioSession.sharedInstance()
        
        do {
            // Configure the session for recording and playback
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            try session.setActive(true)
            // Set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 128000,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // Create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            if let player = player {
                player.stop()
                player.currentTime = 0.0
            }
            // Changing record icon to stop icon
            isRecording = true
            recordButton.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
            recordButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        catch let error {
            print("Failed to record: \(error)")
        }
    }
    
    func finishRecording() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            // Configure the session for recording and playback
            try session.setCategory(AVAudioSession.Category.playback)
            try session.setActive(true)
        }
        catch let error {
            print("Failed to record: \(error)")
        }
        audioRecorder?.stop()
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        isRecording = false
        recordButton.imageEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
    }
}



