//
//  AvailableActions.swift
//  DoItOrElse2
//
//  Created by jose on 3/16/24.
//

import Foundation

public struct Punishment: Hashable {
    var name: String
    var description: String
    var url: String
}

public let Punishments: [Punishment] = [
    Punishment(name: "Donate to the Republican party", description: "What's worse than setting your money on fire? Sending it to the Republican Party... It's a good motivator though.",
               url: "https://secure.winred.com/rnc/presumptive-nominee-congratulations-card-nd?amtposition=3&recurring=false&money_bomb=false&utm_medium=web&utm_source=organic&utm_campaign=20240308_w000156_trump-congrats-card_gop_rnc&exitintent=true"),
    Punishment(name: "Donate to the Mob Museum", description: "🤌🤌🤌", url: "https://themobmuseum.org/support-us/#donate"),
    Punishment(name: "Donate to the Chicago food bank", description: "", url: "https://www.chicagosfoodbank.org/?form=FUNPLFKMYZV"),
    Punishment(name: "Donate to Guitars over Guns", description: "", url: "https://www.classy.org/give/352794/#!/donation/checkout")

]
