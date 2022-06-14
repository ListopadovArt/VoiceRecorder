
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
    lazy var progressView: UISlider = {
        let view = UISlider()
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(arraySound)
    }
    
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(recordButton)
        view.addSubview(progressView)
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
        progressView.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 5).isActive = true
        progressView.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
    
    // MARK: - Prime functions
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
    
    func playSound(file: String){
        do {
            let audioDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let audioUrl = audioDirectory?.appendingPathComponent(file)
            let sound = try AVAudioPlayer(contentsOf: audioUrl!)
            self.player = sound
            sound.delegate = self
            sound.prepareToPlay()
            progressView.value = 0.0
            progressView.maximumValue = Float((player?.duration)!)
            sound.play()
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        } catch {
            print("error loading file")
        }
    }
    
    @objc func updateSlider(){
        progressView.value = Float(player.currentTime)
    }
    
    @objc func timeSliderChanged(sender: UISlider) {
        guard let audioPlayer = player else {
            return
        }
        audioPlayer.currentTime = Double(sender.value)
        audioPlayer.play()
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
        cell.delegate = self
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayTableViewCell", for: indexPath) as? PlayTableViewCell else {
            return
        }
        if let player = self.player {
            cell.progressView.setProgress(Float(player.currentTime / player.duration), animated: true)
        }
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


//MARK: - PlayTableViewCellDelegate Method
extension ViewController: PlayTableViewCellDelegate{
    func cellButtonCliked(buttonTappedFor audio: String) {
        self.playSound(file: audio)
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



