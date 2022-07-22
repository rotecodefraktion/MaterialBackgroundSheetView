//
//  ContentView.swift
//  MaterialBackgroundSheetView
//
//  Created by David Krcek on 22.07.22.
//

import SwiftUI

struct ContentView: View {
    
    let image = UIImage(named: "Image1")
    @State private var offset: CGSize = CGSize(width: 0, height: 230)
    
    var body: some View {
        ZStack {
            imageView
                .overlay {
                    sheetView
                        
                }
        }
        
    }
    
}

//MARK: - View Extension
extension ContentView {
    var imageView: some View {
        Image(uiImage: image!)
            .resizable()
            .clipped()
            .scaledToFill()
            .frame(maxWidth: UIScreen.main.bounds.width)
            .ignoresSafeArea()
    }
    //MARK: - Sheet View
    var sheetView: some View {
        VStack {
            Spacer()
            ZStack(alignment: .center) {
                Rectangle()
                    .opacity(0.5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 50, height: 5)
                            .foregroundColor(Color(uiColor: .lightGray))
                        
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 55)
                    .onTapGesture(count: 2, perform: {
                        withAnimation {
                            offset.height = offset == .zero ? 230 : 0
                            
                        }
                    })
                    
                    Spacer()
                    
                }
                VStack {
                    imageProperties
                }
                
            }
            .frame(width:  UIScreen.main.bounds.width)
            .frame(height: UIScreen.main.bounds.height / 3)
            .offset(offset)
            .gesture(DragGesture()
                .onChanged { value in
                    withAnimation(.spring()) {
                        if offset.height > value.translation.height && value.translation.height < 50 {
                            offset = .zero
                            return
                        }
                        if value.translation.height > 180 {
                            offset.height = 230
                            return
                        }
                        offset.height = value.translation.height
                    }
                }
                .onEnded({ _ in
                    withAnimation(.spring()) {
                        if offset.height < 100 { offset = .zero
                        } else {
                            offset.height = UIScreen.main.bounds.height / 3 - 50
                        }
                    }
                })
            )
        }.ignoresSafeArea()
    }
    
    //MARK: Image Properties View
    var imageProperties: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let properties = imageProperties(for: image?.pngData()) {
                HStack {
                    Image(systemName: "loupe")
                    Text(properties["profil"] ?? "")
                }
                HStack {
                    Image(systemName: "arrow.left.and.right.square")
                    Text(properties["width"] ?? "")
                    Text("Pixel")
                }
                HStack {
                    Image(systemName: "arrow.up.and.down.square")
                    Text(properties["height"] ?? "")
                    Text("Pixel")
                }
            }
        }
        .padding(.top)
        .foregroundColor(Color(.systemGray5))
        .font(.title)
    }
    
}
//MARK: - Function Extenision

extension ContentView{
    func imageProperties(for imageData: Data?) -> [String:String] {
        var imageProperties : [String: String] = [:]
        guard let data = imageData else {
            return [:]
        }
        let options = [kCGImageSourceShouldCache: kCFBooleanFalse]
        if let saveImageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
           let saveImageProperties = CGImageSourceCopyPropertiesAtIndex(saveImageSource, 0, nil) as? [CFString: Any] {
            imageProperties["profil"] = saveImageProperties[kCGImagePropertyProfileName] as? String
            imageProperties["width"] = String("\(saveImageProperties[kCGImagePropertyPixelWidth] as? Int ?? 0)")
            imageProperties["height"] = String("\(saveImageProperties[kCGImagePropertyPixelHeight] as? Int ?? 0)")
        }
        return imageProperties
    }
}

//MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
