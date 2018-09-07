//
//  Functions.swift
//  MyLocations
//
//  Created by 管君 on 9/7/18.
//  Copyright © 2018 管君. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
