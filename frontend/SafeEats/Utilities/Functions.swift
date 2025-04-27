//
//  Functions.swift
//  SafeEats
//
//  Created by Aditi Patel on 4/17/25.
//
import Foundation

func priceToDollarSigns(_ price: Int?) -> String {
    switch price {
    case 1: return "$"
    case 2: return "$$"
    case 3: return "$$$"
    case 4: return "$$$$"
    default: return "No price"
    }
}
