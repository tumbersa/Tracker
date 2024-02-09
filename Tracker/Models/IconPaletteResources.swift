//
//  IconPalette.swift
//  Tracker
//
//  Created by Глеб Капустин on 25.01.2024.
//

import UIKit

enum IconPaletteResources{
    static let emojis: [String] = ["🙂","😻","🌺","🐶", "❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    static let colors: [UIColor] = [
        ColorResource.trRedPalette,
        ColorResource.trOrangePalette,
        ColorResource.trBluePalette,
        ColorResource.trDarkPurplePalette,
        ColorResource.trSaturatedGreenPalette,
        ColorResource.trDarkPinkPalette,
        ColorResource.trSoftPinkPalette,
        ColorResource.trLightBluePalette,
        ColorResource.trMintyGreenPalette,
        ColorResource.trDarkBluePalette,
        ColorResource.trVibrantOrangePalette,
        ColorResource.trLightPinkPalette,
        ColorResource.trBeigePalette,
        ColorResource.trSkyBluePalette,
        ColorResource.trVioletPalette,
        ColorResource.trLavenderPalette,
        ColorResource.trSoftLavenderPalette,
        ColorResource.trMediumGreenPalette
    ].map({UIColor(resource: $0)})
    
}
