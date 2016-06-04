//
//  ViewController.swift
//  FontSample
//
//  Created by Hideko Ogawa on 6/4/16.
//  Copyright © 2016 SoraUsagi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textSegment:UISegmentedControl!
    @IBOutlet weak var styleStepper:UIStepper!
    @IBOutlet weak var sizeStepper:UIStepper!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var labelImage:UIImageView!
    @IBOutlet weak var ascenderLabel:UILabel!
    @IBOutlet weak var descenderLabel:UILabel!
    @IBOutlet weak var capHeightLabel:UILabel!
    @IBOutlet weak var xHeightLabel:UILabel!
    @IBOutlet weak var lineHeightLabel:UILabel!
    @IBOutlet weak var leadingLabel:UILabel!
    @IBOutlet weak var widthLabel:UILabel!
    @IBOutlet weak var heightLabel:UILabel!
    @IBOutlet weak var fontFamilyLabel:UILabel!
    @IBOutlet weak var fontSizeLabel:UILabel!

    @IBOutlet weak var diffFontSegment:UISegmentedControl!
    @IBOutlet weak var diffScaleLabel:UILabel!
    @IBOutlet weak var diffKernSlider:UISlider!
    @IBOutlet weak var diffKernLabel:UILabel!
    @IBOutlet weak var diffWidthLabel:UILabel!
    @IBOutlet weak var diffHeightLabel:UILabel!
    @IBOutlet weak var diffFontSlider:UISlider!
    @IBOutlet weak var diffFontLabel:UILabel!
    @IBOutlet weak var diffImageHeightConstraint:NSLayoutConstraint!
    
    
    let weights:[CGFloat] = [UIFontWeightUltraLight, UIFontWeightThin, UIFontWeightLight, UIFontWeightRegular, UIFontWeightMedium, UIFontWeightSemibold, UIFontWeightBold, UIFontWeightHeavy, UIFontWeightBlack]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diffScaleLabel.text = "@\(Int(UIScreen.mainScreen().scale))x"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        //printDebug()
    }

    @IBAction func didChangeText(segment:UISegmentedControl) {
        let text = segment.titleForSegmentAtIndex(segment.selectedSegmentIndex)
        label.text = text
        updateUI()
    }

    @IBAction func didChangeFontSize(stepper:UIStepper) {
        let font = UIFont.systemFontOfSize(CGFloat(stepper.value), weight: weights[Int(styleStepper.value)])
        label.font = font
        updateUI()
    }

    @IBAction func didChangeFontWeight(stepper:UIStepper) {
        let size = label.font.pointSize
        label.font = UIFont.systemFontOfSize(size, weight: weights[Int(styleStepper.value)])
        updateUI()
    }

    @IBAction func didChangeDiffFont(segment:UISegmentedControl) {
        updateDiffImage()
    }
    
    private func updateUI() {
        label.setNeedsLayout()
        label.layoutIfNeeded()
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 2
        widthLabel.text = formatter.stringFromNumber(label.bounds.size.width)
        heightLabel.text = formatter.stringFromNumber(label.bounds.size.height)
        fontFamilyLabel.text = label.font.fontName
        fontSizeLabel.text = formatter.stringFromNumber(label.font.pointSize)
        
        ascenderLabel.text = formatter.stringFromNumber(label.font.ascender)
        descenderLabel.text = formatter.stringFromNumber(label.font.descender)
        capHeightLabel.text = formatter.stringFromNumber(label.font.capHeight)
        xHeightLabel.text = formatter.stringFromNumber(label.font.xHeight)
        lineHeightLabel.text = formatter.stringFromNumber(label.font.lineHeight)
        leadingLabel.text = formatter.stringFromNumber(label.font.leading)
        
        //detect font size
        var fontSize = Float(label.font.pointSize)
        if textSegment.selectedSegmentIndex == 1 {
            fontSize = targetFontSize(label.font.pointSize)
        }
        diffFontSlider.minimumValue = fontSize - 2
        diffFontSlider.maximumValue = fontSize + 2
        diffFontSlider.value = fontSize
        diffFontLabel.text = formatter.stringFromNumber(fontSize)
        
        //detect kern
        var kern:Float = 0
        if textSegment.selectedSegmentIndex == 0 {
        let width = textSize(diffTextAttributes(0)).width
            kern = targetKern(0, targetWidth: label.bounds.size.width, increase: label.bounds.size.width > width)
        }
        diffKernSlider.minimumValue = kern - 1
        diffKernSlider.maximumValue = kern + 1
        diffKernSlider.value = kern
        diffKernLabel.text = formatter.stringFromNumber(kern)
        
        updateDiffImage()
    }

    private func updateDiffImage() {
        let image = imageOfLabel()
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.drawAtPoint(CGPointZero)
        let textImage = imageOfDrawText()
        textImage.drawAtPoint(CGPoint(x: 0, y: (image.size.height - textImage.size.height) / 2))
        let mixImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        labelImage.image = mixImage
        diffImageHeightConstraint.constant = mixImage.size.height
    }
    
    private func targetFontSize(fontSize:CGFloat) -> Float {
        let font = UIFont(name: label.font.fontName, size: CGFloat(fontSize))!
        let width = textSize(textAttributes(font)).width
        if width > label.bounds.size.width {
            return targetFontSize(fontSize - 0.01)
        } else {
            return Float(fontSize)
        }
    }
    
    private func textSize(attribute:[String : AnyObject]) -> CGSize {
        let string = label.text!
        let textRect = NSString(string: string).boundingRectWithSize(self.view.frame.size, options: .UsesLineFragmentOrigin, attributes: attribute, context: nil)
        return textRect.size
    }

    private func textAttributes(font:UIFont) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = label.textAlignment
        return [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
    }
    
    private func diffTextAttributes(kern:Float) -> [String : AnyObject] {
        let fontName = diffFontSegment.selectedSegmentIndex == 0 ? label.font.fontName : diffFontSegment.titleForSegmentAtIndex(1)!
        let font = UIFont(name: fontName, size: CGFloat(diffFontSlider.value))!
        var attributes = textAttributes(font)
        attributes[NSForegroundColorAttributeName] = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.7)
        attributes[NSKernAttributeName] = kern
        return attributes
    }

    private func targetKern(kern:Float, targetWidth:CGFloat, increase:Bool) -> Float {
        let width = textSize(diffTextAttributes(kern)).width
        if targetWidth == width { return kern }
        if increase {
            if targetWidth < width {
                return kern - 0.01
            } else {
                return targetKern(kern + 0.01, targetWidth: targetWidth, increase: increase)
            }
        } else {
            if targetWidth > width {
                return kern
            } else {
                return targetKern(kern - 0.01, targetWidth: targetWidth, increase: increase)
            }
        }
    }

    private func imageOfDrawText() -> UIImage {
        let attributes = diffTextAttributes(diffKernSlider.value)
        let size = textSize(attributes)

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 2
        diffKernLabel.text = formatter.stringFromNumber(diffKernSlider.value)
        diffWidthLabel.text = formatter.stringFromNumber(size.width)
        diffHeightLabel.text = formatter.stringFromNumber(size.height)
        diffFontLabel.text = formatter.stringFromNumber(diffFontSlider.value)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        label.text!.drawWithRect(CGRect(origin: CGPointZero, size:size), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(CGImage: img.CGImage!, scale: 1.0, orientation: .Up)
    }

    private func imageOfLabel() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.drawViewHierarchyInRect(CGRect(origin: CGPointZero, size:label.bounds.size), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .Up)
    }

    //MARK: Debug Print
    
    private func printDebug() {
        print("| Label Font Size | Label Font Name | Label Text | Real Font Size | Char Space | Label Height|")
        print("|:---------:|----------| ----- |----------:|----------:|----------:|")
        printDebugLine()
        
        textSegment.selectedSegmentIndex = 1
        didChangeText(textSegment)
        printDebugLine()
        
        for _ in 0..<22 {
            textSegment.selectedSegmentIndex = 0
            didChangeText(textSegment)
            sizeStepper.value += 1
            didChangeFontSize(sizeStepper)
            printDebugLine()
            textSegment.selectedSegmentIndex = 1
            didChangeText(textSegment)
            printDebugLine()
        }
    }
    
    private func printDebugLine() {
        print("|", fontSizeLabel.text! , "|", fontFamilyLabel.text!, "|", label.text!, "|", diffFontLabel.text!, "|", diffKernLabel.text!, "|", heightLabel.text!, "|")
    }
    
}

