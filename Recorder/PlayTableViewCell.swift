//
//  PlayTableViewCell.swift
//  Recorder
//
//  Created by Artem Listopadov on 6/9/21.
//  Copyright © 2021 Artem Listopadov. All rights reserved.
//

import UIKit
import AVFoundation

class PlayTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var progressSlider: UISlider = {
        let view = UISlider()
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        return view
    }()
    
    var player: AVAudioPlayer!
    var audio: String!
    var timer: Timer?
    
    // MARK: - Prime functions
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(progressSlider)
        
        titleLabel.topAnchor.constraint(equalTo: playButton.topAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: progressSlider.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        progressSlider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10).isActive = true
        progressSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        progressSlider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
    }
    
    func configure(with object: String) {
        self.titleLabel.text = "\(object)"
    }
}


//MARK: - Actions
extension PlayTableViewCell {
    @objc func play(sender: UIButton) {
        if let audio = audio {
            do {
                let audioDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let audioUrl = audioDirectory?.appendingPathComponent(audio)
                let sound = try AVAudioPlayer(contentsOf: audioUrl!)
                self.player = sound
                sound.prepareToPlay()
                progressSlider.value = 0.0
                progressSlider.maximumValue = Float((player?.duration)!)
                sound.play()
                timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            } catch {
                print("error loading file")
            }
        }
    }
    
    @objc func updateSlider(){
        progressSlider.value = Float(player.currentTime)
    }
    
    @objc func timeSliderChanged(sender: UISlider) {
        guard let audioPlayer = player else {
            return
        }
        audioPlayer.currentTime = Double(sender.value)
        audioPlayer.play()
    }
}
