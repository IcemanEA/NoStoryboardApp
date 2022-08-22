//
//  Product.swift
//  NoStoryboardApp
//
//  Created by Egor Ledkov on 22.08.2022.
//
struct Product {
    let name: String
    let description: String
    let price: Int
    
    var priceString: String {
        "\(price.formatted(.number.grouping(.automatic))) ₽"
    }
}
