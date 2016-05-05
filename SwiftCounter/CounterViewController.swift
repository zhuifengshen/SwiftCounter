//
//  CounterViewController.swift
//  SwiftCounter
//
//  Created by 张楚昭 on 16/5/4.
//  Copyright © 2016年 tianxing. All rights reserved.
//

import Foundation
import UIKit

class CounterViewController: UIViewController {
    //UI Controls
    var timeLabel:UILabel? //显示剩余时间
    var timeButtons:[UIButton]? //设置时间的按钮数组
    var startStopButton:UIButton? //启动/停止按钮
    var clearButton:UIButton? //复位按钮
    let timeButtonInfos = [("1分", 60), ("3分", 180), ("5分", 300), ("秒", 1)]
    //剩余秒数
    var remainingSeconds:Int = 0{
        willSet(newSeconds){
            let mins = newSeconds / 60
            let seconds = newSeconds % 60
            self.timeLabel!.text = NSString(format: "%02d:%02d", mins, seconds) as String
        }
    }
    var timer:NSTimer?
    //计时器状态
    var isCounting:Bool = false{
        willSet(newValue){
            if newValue{
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            }else{
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonsEnabled(!newValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.whiteColor()
        setupTimeLabel()
        setupTimeButtons()
        setupActionButtons()
    }
    
    //视图大小改变时调用的方法
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width - 20, 120)
        
        let gap = (self.view.bounds.size.width - 10 * 2 - (CGFloat(timeButtons!.count) * 64)) / CGFloat(timeButtons!.count - 1)
        for (index, button) in timeButtons!.enumerate(){
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height - 120, 64, 44)
        }
        
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height - 60, self.view.bounds.size.width - 20 - 100, 44)
        clearButton!.frame = CGRectMake(10 + self.view.bounds.size.width - 20 - 100 + 20, self.view.bounds.size.height - 60, 80, 44)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //UI Helpers
    func setupTimeLabel(){
        timeLabel = UILabel()
        timeLabel!.text = "00:00"
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Helvetica", size: 80)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center
        self.view.addSubview(timeLabel!)
    }
    func setupTimeButtons(){
        var buttons = [UIButton]()
        for(index, (title, _)) in timeButtonInfos.enumerate(){
            let button = UIButton()
            button.tag = index //保存按钮的 index
            button.setTitle("\(title)", forState: UIControlState.Normal)
            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            buttons.append(button)
            self.view.addSubview(button)
        }
        timeButtons = buttons
    }
    func setupActionButtons(){
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        startStopButton!.setTitle("启动/停止", forState:  UIControlState.Normal)
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(startStopButton!)
        
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        clearButton!.setTitle("复位", forState:  UIControlState.Normal)
        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(clearButton!)
    }
    //回调方法
    func timeButtonTapped(sender:UIButton){
        let (_, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
    }
    func startStopButtonTapped(sender:UIButton){
        isCounting = !isCounting
        
        if isCounting{
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        }else{
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    func clearButtonTapped(sender:UIButton){
        remainingSeconds = 0
    }
    func updateTimer(timer:NSTimer){
        remainingSeconds -= 1
        
        if remainingSeconds <= 0{
            self.isCounting = false
            self.timeLabel?.text = "00:00"
            self.remainingSeconds = 0
            
            let alert = UIAlertView()
            alert.title = "计时完成!"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    func setSettingButtonsEnabled(enabled:Bool){
        for button in self.timeButtons!{
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }
    func createAndFireLocalNotificationAfterSeconds(seconds:Int){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        let timerIntervalSinceNow = NSNumber(integer: seconds).doubleValue
        notification.fireDate = NSDate(timeIntervalSinceNow: timerIntervalSinceNow)
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = "计时完成!!!"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}