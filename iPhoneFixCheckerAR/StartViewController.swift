//
//  HomeViewController.swift
//  ARKitImageRecognition
//
//  Created by 陳裕銘 on 2020/1/13.
//  Copyright © 2020 Jayven Nhan. All rights reserved.
//

import UIKit

class StartViewController: UIViewController,UIScrollViewDelegate//使用UIScrollView需要使用協定
{
    //將程式碼與ＵＩ物件連結
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //設定要顯示在導覽頁面圖片的名稱
    let imageArray = ["phone","recognition","indicatior"]
    
    //此變數為頁面指示器的當前頁面位置
    var page = 0
    
    //此變數為判斷使用者是否第一次使用此App
    var isFirstLoad = true
    
    //App開始載入記憶體
    override func viewDidLoad() {
        super.viewDidLoad()
        //讓StartViewController成為scrollView的委派
        scrollView.delegate = self
        
        //隱藏導覽列的標題
        navigationController?.isNavigationBarHidden = true
        
        //螢幕下方的介紹文字
         introLabel.text = "將維修完的手機置於平面上"
        
        //文字適應寬度而縮小
        introLabel.adjustsFontSizeToFitWidth = true
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        scrollView.contentSize.width = view.frame.width * CGFloat(imageArray.count)
        
       
        if isFirstLoad{
            isFirstLoad = false
            for image in 0..<imageArray.count
            {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                
                imageView.frame = CGRect(x: view.frame.width * CGFloat(image), y: 0, width: view.frame.width, height: scrollView.frame.height)
                //            imageView.clipsToBounds = true
                imageView.image = UIImage(named: imageArray[image])
                scrollView.addSubview(imageView)
                print(image)
                page = Int(scrollView.contentSize.width / scrollView.frame.width) - 1
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("View.width:\(view.frame.width)")
        print("ScrollView.frame.width:\(scrollView.frame.width)")
    }
    //導覽說明的程式碼，當頁面進行滑動，下方介紹文字跟圖片跟著變換
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch floor(scrollView.contentOffset.x / scrollView.frame.size.width)
        {
        case 0 :
            introLabel.text = "將維修完的手機置於平面上"
            self.pageControl.currentPage = 0
        case 1:
            introLabel.text = "將鏡頭對準維修完的手機，進行偵測"
            self.pageControl.currentPage = 1
        case 2:
            introLabel.text = "確認指示點的每一個螺絲都有鎖，即可將手機組裝完成"
            self.pageControl.currentPage = 2
        default:
            introLabel.text = "Error: Diaplay Wrong"
        }
    }
    
 
}

