//
//  AtomView.swift
//  SwiftyProtein
//
//  Created by Сергей on 25.08.2021.
//

import UIKit

class AtomView: UIView {
	
	var view: UIView!

	@IBOutlet weak var symbolLabel: UILabel!
	@IBOutlet weak var nameEnLabel: UILabel!
	@IBOutlet weak var nameRuLabel: UILabel!
	@IBOutlet weak var ordinalLabel: UILabel!
	@IBOutlet weak var atomicMassLabel: UILabel!
	@IBOutlet weak var electronShellConfigLabel: UILabel!
	@IBOutlet weak var atomicNumberLabel: UILabel!
	@IBOutlet weak var atomicWeightLabel: UILabel!
	
	@IBOutlet var levelsLabels: [UILabel]!
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		xibSetup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func xibSetup() {
		view = loadViewFromNib()
		view.frame = bounds
		view.backgroundColor = .white
		view.autoresizingMask = .ArrayLiteralElement(arrayLiteral: .flexibleWidth, .flexibleHeight)
		addSubview(view)
	}
	
	func loadViewFromNib() -> UIView {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "AtomView", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		
		return view
	}

}
