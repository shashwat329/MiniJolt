//
//  animatedLaunchScreen.swift
//  patna metro
//
//  Created by shashwat singh on 15/05/25.
//

import SwiftUI

struct animatedLaunchScreen: View {
    var body: some View {
        ZStack{
            Color(Color.black)
                .ignoresSafeArea()
            VStack{
                Spacer()
                LottieView(filename: "launchscreenanimation")
                    .frame(maxWidth: .infinity)
                
                    
            }
            .ignoresSafeArea(edges: [.leading,.trailing,.top])
        }
       
    }
}

#Preview {
    animatedLaunchScreen()
}
