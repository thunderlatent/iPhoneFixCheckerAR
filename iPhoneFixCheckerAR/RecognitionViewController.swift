//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jimmy Chen



import UIKit
//導入框架庫，才能使用ARKit的功能
import ARKit

class RecognitionViewController: UIViewController {
    //loadIndicator為當頁面等待時，讓使用者明白是頁面還沒跑完，而不是當機
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    //ARSCNView為顯示AR體驗的視圖
    @IBOutlet weak var sceneView: ARSCNView!
    //此標籤為顯示辨識到的機型
    @IBOutlet weak var label: UILabel!
    //此變數為進行二階段辨識所需的參數
    var stageNumber = 0
    //此變數為儲存機型名稱
    var imageName = ""
    //此字典為讓辨識到的特徵區塊名稱轉換為使用者所熟知的機型名稱
    let phoneNameDict: [String:String] = ["iphone7-TE":"iPhone7",
                                          "iphone7-TE-1":"iPhone7",
                                          "iphone7Plus-TE":"iPhone7 Plus",
                                          "iphone7Plus-TE-1":"iPhone7 Plus",
                                          "iphone8-battery-detail":"iPhone8",
                                          "iphone8-TE":"iPhone8",
                                          "iphone8Plus-TE":"iPhone8 Plus",
                                          "iPhone8Plus-TE-1":"iPhone8 Plus",
                                          "iPhone 11 Pro Max":"iPhone 11 Pro Max",
                                          "iPhone 11 Pro":"iPhone 11 Pro"]
    
    //此變數為控制維修資訊顯示時的動畫時
    var imageHightLightAction:SCNAction{
        return .sequence([.wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.4)
            ])
    }
    var success = 0
    var fail = 0
   var total = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()

        loadIndicator.startAnimating()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false

        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetTrackingConfiguration()
        self.loadIndicator.stopAnimating()
        self.loadIndicator.isHidden = true
        
    }

    //MARK: 添加照明
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    //MARK:
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
        DispatchQueue.main.async
            {
                self.navigationItem.title = "辨識機型"
        }
    }
    
    
    
    
    
}
//MARK: 遵從ARScnViewDelegate協定
extension RecognitionViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if stageNumber == 0
//        {
        total += 1
//            self.sceneView.session.pause()
//            stageNumber = 1
        
            guard let imageAnchor = anchor as? ARImageAnchor else{return}
            let referenceImage = imageAnchor.referenceImage
//            print("At stage 0, I detect referenceImage.name: \(referenceImage.name!)")
            if let resourceName: String = phoneNameDict[referenceImage.name!]
            {
                if resourceName == "iPhone7"
                {
                    self.success += 1
                }else{
                    self.fail += 1
                }
//                DispatchQueue.main.async
//                    {
//                        self.messageAlert(resourceImage: resourceName)
//                }
                imageName = resourceName
            }else
            {
                resetTrackingConfiguration()
//                print("I got a nil in resourceName")
            }
//        }else if stageNumber == 1
//        {
//            stageNumber = 0
//            guard let imageAnchor = anchor as? ARImageAnchor else{return}
//            let referenceImage = imageAnchor.referenceImage
//            print("At stage 1, I detect referenceImage.name: \(referenceImage.name!)")
//
//            let plane = SCNPlane(width: referenceImage.physicalSize.width * 3, height: referenceImage.physicalSize.height)
//            plane.firstMaterial?.diffuse.contents = UIImage(named: "\(self.imageName)Mask")
//            var planeNode = SCNNode()
//            planeNode = SCNNode(geometry: plane)
//            planeNode.eulerAngles.x = -Float.pi / 2
//            planeNode.runAction(imageHightLightAction)
//            node.addChildNode(planeNode)
//            DispatchQueue.main.async
//                {
//                    self.navigationItem.title = "完工檢查"
//            }
//        }
        DispatchQueue.main.async {
            self.label.text = "偵測到:\(self.imageName)"
        }
        print("總共跑了\(self.total)次，成功\(self.success)次，誤判\(self.fail)次")
        resetTrackingConfiguration()
    }
   
    
   
    //MARK:重置ARConfiguration
    func resetTrackingConfiguration()
    {
        self.stageNumber = 0
        //將Assets.xcassets(圖片資源庫)內名為"feature"的資料夾，當作辨識特徵點的來源。
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "feature", bundle: nil) else{return}
        //這是一個可以執行提供裝置上六個自由度軌跡，來找到場景所需的特徵點設定
        let configuration = ARWorldTrackingConfiguration()
        //將referenceImages設定為要辨識的圖像
        configuration.detectionImages = referenceImages
        
//        print("Here is restTrackingCnfiguration()")
        //設定要使用的組態
        let options:ARSession.RunOptions = [.resetTracking,.removeExistingAnchors]
        //將組態加入至sceneView
        self.sceneView.session.run(configuration, options: options)
        self.imageName.removeAll()
        //因為是UI物件，所以用主執行緒跑
        DispatchQueue.main.async {
            self.label.text = "Move camera around to detect images"
        }
    }
    
    //MARK: 第二階段(stageNumber = 1)
    func secondTrackingConfigutation(_ inGropNamed: String)
    {
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: inGropNamed, bundle: nil)
        {
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = referenceImages
            let options:ARSession.RunOptions = [.resetTracking,.removeExistingAnchors]
            
            
            sceneView.session.run(configuration, options: options)
            for referenceImage in referenceImages
            {
                print("second times I got \(referenceImage.name!)")
            }
        }else
        {
            print("error:secondTrackingConfigutation(:)")
        }
       
        
    }
    //MARK:跳出確認訊息，並且進入第二階段
    
    func messageAlert(resourceImage:String)
    {
       
                let alert = UIAlertController(title: "偵測到機型為\(resourceImage)", message: "按下確認後請繼續對準手機，並請稍待指示圖顯示", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "確認", style: .default)
                { (action) in
                    self.secondTrackingConfigutation(resourceImage)
                    
                }
                alert.addAction(OKAction)
                
                present(alert, animated: true, completion: nil)
        
        
    }
    
}
