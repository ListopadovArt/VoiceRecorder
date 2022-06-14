//
//  PlayTableViewCell.swift
//  Recorder
//
//  Created by Artem Listopadov on 6/9/21.
//  Copyright © 2021 Artem Listopadov. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayTableViewCellDelegate: AnyObject {
    func cellButtonCliked(buttonTappedFor audio: String )
}

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
    lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.trackTintColor = .darkGray
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var player: AVAudioPlayer!
    weak var delegate: PlayTableViewCellDelegate?
    var audio: String!
    
    
    // MARK: - Prime functions
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(progressView)
        titleLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        progressView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10).isActive = true
        progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
    }
    
    func configure(with object: String) {
        self.titleLabel.text = "\(object)"
    }
    
    @objc func play(sender: UIButton) {
        if let audio = audio,
           let delegate = delegate {
            delegate.cellButtonCliked(buttonTappedFor: audio)
        }
    }
}
