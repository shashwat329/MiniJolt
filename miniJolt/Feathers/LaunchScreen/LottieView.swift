//
//  lottieView.swift
//  patna metro
//
//  Created by shashwat singh on 15/05/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: filename)
        animationView.loopMode = .repeat(2)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
//
//#Preview {
//    LottieView(filename: "lauchscreenanimation")
//}
