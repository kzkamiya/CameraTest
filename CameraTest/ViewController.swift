//
//  ViewController.swift
//  CameraTest
//
//  Created by me on 2019/03/18.
//  Copyright © 2019 Neosystem. All rights reserved.
//
// References:
// https://qiita.com/t_okkan/items/f2ba9b7009b49fc2e30a
// https://guides.codepath.com/ios/Creating-a-Custom-Camera-View

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        if setupDevice() {
            setupInputOutput()
            setupPreviewLayer()
            captureSession.startRunning()
            styleCaptureButton()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .auto
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    var mFirstStart = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (mFirstStart) {
            mFirstStart = false
            detectOrientation()
        }
    }
    
    func detectOrientation() {

//        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
//            print("Landscape Left")
//            // プレビューレイヤの表示の向きを設定
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//
//        }
//        else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
//            print("Landscape Right")
//            // プレビューレイヤの表示の向きを設定
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
//        }
//        else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown{
//            print("Portrait Upside Down")
//            // プレビューレイヤの表示の向きを設定
////            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
//        }
//        else if UIDevice.current.orientation == UIDeviceOrientation.portrait {
//            print("Portrait")
//            // プレビューレイヤの表示の向きを設定
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        }
        
        DispatchQueue.main.async {
            self.cameraPreviewLayer?.frame = self.view.bounds
        }

        let orient = UIDevice.current.orientation
        switch orient {
        case .portrait:
            print("Portrait")
            // プレビューレイヤの表示の向きを設定
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            print("PortraitUpsideDown")
            // プレビューレイヤの表示の向きを設定
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft :
            print("landscapeLeft")
            // プレビューレイヤの表示の向きを設定、なぜか逆にしないと逆さまになる。
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight

        case .landscapeRight :
            print("landscapeRight")
            // プレビューレイヤの表示の向きを設定、なぜか逆にしないと逆さまになる。
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft

        default:
            print("Anything But Portrait")
            // プレビューレイヤの表示の向きを設定
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }

        
        
//        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
//            // プレビューレイヤの表示の向きを設定
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
//        } else {
//            print("Portrait")
//            // プレビューレイヤの表示の向きを設定
//            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        detectOrientation()
    }}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension ViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
        }
    }
}

//MARK: カメラ設定メソッド
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() -> Bool {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        if (mainCamera != nil) {
            // 起動時のカメラを設定
            currentDevice = mainCamera
            return true
        } else {
            return false
        }
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    // ボタンのスタイルを設定
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
}
