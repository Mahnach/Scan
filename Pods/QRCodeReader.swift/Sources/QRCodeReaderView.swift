/*
 * QRCodeReader.swift
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit


final public class QRCodeReaderView: UIView, QRCodeReaderDisplayable {
    
    
  public lazy var overlayView: UIView? = {
    let ov = ReaderOverlayView()

    ov.backgroundColor                           = .clear
    ov.clipsToBounds                             = true
    ov.translatesAutoresizingMaskIntoConstraints = false

    return ov
  }()

  public let cameraView: UIView = {
    let cv = UIView()

    cv.clipsToBounds                             = true
    cv.translatesAutoresizingMaskIntoConstraints = false

    return cv
  }()

  public lazy var cancelButton: UIButton? = {
    let cb = UIButton()

    cb.translatesAutoresizingMaskIntoConstraints = false

    cb.setBackgroundImage(UIImage(named: "cancel"), for: .normal)

    return cb
  }()

  public lazy var switchCameraButton: UIButton? = {
    let scb = SwitchCameraButton()

    scb.translatesAutoresizingMaskIntoConstraints = false

    return scb
  }()

  public lazy var toggleTorchButton: UIButton? = {
    let ttb = ToggleTorchButton()

    ttb.translatesAutoresizingMaskIntoConstraints = false

    return ttb
  }()

  private weak var reader: QRCodeReader?

  public func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool, reader: QRCodeReader?) {
    self.reader = reader

    addComponents()

    cancelButton?.isHidden       = !showCancelButton
    switchCameraButton?.isHidden = !showSwitchCameraButton
    toggleTorchButton?.isHidden  = !showTorchButton
    overlayView?.isHidden        = !showOverlayView

    guard let cb = cancelButton, let scb = switchCameraButton, let ttb = toggleTorchButton, let ov = overlayView else { return }

    let views = ["cv": cameraView, "ov": ov, "cb": cb, "scb": scb, "ttb": ttb]

    
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))



    if showSwitchCameraButton {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scb(50)]", options: [], metrics: nil, views: views))
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[scb(70)]|", options: [], metrics: nil, views: views))
    }

    if showTorchButton {
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[ttb(50)]", options: [], metrics: nil, views: views))
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ttb(70)]", options: [], metrics: nil, views: views))
    }

    for attribute in Array<NSLayoutAttribute>([.left, .top, .right, .bottom]) {
      addConstraint(NSLayoutConstraint(item: ov, attribute: attribute, relatedBy: .equal, toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
   
    let offset = "\(cameraView.frame.width / 2 - 47.5)"
    guard let cb = cancelButton, let scb = switchCameraButton, let ttb = toggleTorchButton, let ov = overlayView else { return }
    
    let views = ["cv": cameraView, "ov": ov, "cb": cb, "scb": scb, "ttb": ttb]


    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv]-10-[cb(35)]-10-|", options: [], metrics: nil, views: views))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(offset)-[cb(95)]|", options: [], metrics: nil, views: views))
   
    let myView = UIView(frame: CGRect(x: 0, y: 0, width: cameraView.frame.width, height: 75))
    myView.backgroundColor = UIColor(red: 231/255, green: 244/255, blue: 246/255, alpha: 1.0)
    
    let labelTitle: UILabel = UILabel()
    labelTitle.frame = CGRect(x: cameraView.frame.width / 2 - 75, y: 21, width: 150, height: 30)
    labelTitle.textColor = UIColor(red: 35/255, green: 181/255, blue: 163/255, alpha: 1.0)
    labelTitle.textAlignment = .center
    labelTitle.font = UIFont.boldSystemFont(ofSize: 17)
    labelTitle.text = "STEP 1"

    let labelText: UILabel = UILabel()
    labelText.frame = CGRect(x: cameraView.frame.width / 2 - 75, y: 48, width: 150, height: 20)
    labelText.textColor = UIColor(red: 106/255, green: 180/255, blue: 164/255, alpha: 1.0)
    labelText.textAlignment = .center
    labelText.text = "Scan QR code"
    
    
    myView.addSubview(labelTitle)
    myView.addSubview(labelText)
    self.cameraView.addSubview(myView)
    //cameraView.bringSubview(toFront: myView)
    
    
    
    
    reader?.previewLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    
  }

  // MARK: - Scan Result Indication

  func startTimerForBorderReset() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
      if let ovl = self.overlayView as? ReaderOverlayView {
        ovl.overlayColor = .white
      }
    }
  }

  func addRedBorder() {
    self.startTimerForBorderReset()

    if let ovl = self.overlayView as? ReaderOverlayView {
      ovl.overlayColor = .red
    }
  }

  func addGreenBorder() {
    self.startTimerForBorderReset()
    
    if let ovl = self.overlayView as? ReaderOverlayView {
      ovl.overlayColor = .green
    }
  }

  @objc func orientationDidChange() {
    setNeedsDisplay()
    overlayView?.setNeedsDisplay()

    if let connection = reader?.previewLayer.connection, connection.isVideoOrientationSupported {
      let orientation                    = UIDevice.current.orientation
      let supportedInterfaceOrientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)

      connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: orientation, withSupportedOrientations: supportedInterfaceOrientations, fallbackOrientation: connection.videoOrientation)
    }
  }

  // MARK: - Convenience Methods

  private func addComponents() {
    NotificationCenter.default.addObserver(self, selector: #selector(QRCodeReaderView.orientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)

    addSubview(cameraView)

    if let ov = overlayView {
      addSubview(ov)
    }

    if let scb = switchCameraButton {
      addSubview(scb)
    }

    if let ttb = toggleTorchButton {
      addSubview(ttb)
    }
    
    if let cb = cancelButton {
      addSubview(cb)
    }

    if let reader = reader {
      cameraView.layer.insertSublayer(reader.previewLayer, at: 0)
      
      orientationDidChange()
    }
  }
}
