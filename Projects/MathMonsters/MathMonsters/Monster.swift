//
//  Monster.swift
//  MathMonsters
//
//  Created by 管君 on 10/18/18.
//  Copyright © 2018 管君. All rights reserved.
//

import UIKit

enum Weapon {
    case blowgun, ninjaStar, fire, sword, smoke
}

class Monster {
    let name: String
    let description: String
    let iconName: String
    let weapon: Weapon
    
    init(name: String, description: String, iconName: String, weapon: Weapon) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.weapon = weapon
    }
    
    var weaponImage: UIImage {
        switch weapon {
        case .blowgun:
            return UIImage(named: "blowgun.png")!
        case .fire:
            return UIImage(named: "fire.png")!
        case .ninjaStar:
            return UIImage(named: "ninjastar.png")!
        case .smoke:
            return UIImage(named: "smoke.png")!
        case .sword:
            return UIImage(named: "sword.png")!
        }
    }
    
    var icon: UIImage? {
        return UIImage(named: iconName)
    }
}
