//
//  Geometry.swift
//  SwiftyProtein
//
//  Created by Сергей on 25.08.2021.
//

import UIKit
import SceneKit

extension Float {
	var radians: Float {
		return self * .pi / 180
	}
	
	var degrees: Float {
		return self  * 180 / .pi
	}
}

extension SCNVector3 {
	mutating func multScalar(scalar: Float) {
		self.x *= scalar
		self.y *= scalar
		self.z *= scalar
	}
	
	func addition(with vector: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(x + vector.x, y + vector.y, z + vector.z)
	}
}

extension SCNVector3 {
	func cross(vector: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
	}
	
	func length() -> Float {
		return sqrt(x * x + y * y + z * z)
	}
	
	func normalized() -> SCNVector3 {
		return self / length()
	}
}

func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
	return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

extension SCNMatrix4 {
	public init(x: SCNVector3, y: SCNVector3, z: SCNVector3, w: SCNVector3) {
		self.init(
			m11: x.x,
			m12: x.y,
			m13: x.z,
			m14: 0.0,
			
			m21: y.x,
			m22: y.y,
			m23: y.z,
			m24: 0.0,
			
			m31: z.x,
			m32: z.y,
			m33: z.z,
			m34: 0.0,
			
			m41: w.x,
			m42: w.y,
			m43: w.z,
			m44: 1.0)
	}
}

func * (left: SCNMatrix4, right: SCNMatrix4) -> SCNMatrix4 {
	return SCNMatrix4Mult(left, right)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
