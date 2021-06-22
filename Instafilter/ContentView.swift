//
//  ContentView.swift
//  Instafilter
//
//  Created by Emile Wong on 15/6/2021.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTIES
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showErrorMessage = false
    @State private var currentFilterName = "Change Filter"
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    // MARK: - FUNCTIONS
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    // MARK: - BODY
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                } //: ZSTACK
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack{
                    Text("Intensity")
                    Slider(value: intensity)
                } //: HSTACK
                .padding(.vertical)
                
                HStack{
                    Button("\(currentFilterName)"){
                        self.showFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save"){
                        if processedImage == nil {
                            showErrorMessage = true
                        }
                        guard let processedImage = self.processedImage else { return }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                    
                } //: HSTACK
            } //: NAVIGATION
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage, content: {
                ImagePicker(image: self.$inputImage)
            })
            .actionSheet(isPresented: $showFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) {
                        currentFilterName = "Crystallize"
                        self.setFilter(CIFilter.crystallize())
                    },
                    .default(Text("Edges")) {
                        currentFilterName = "Edges"
                        self.setFilter(CIFilter.edges())
                    },
                    .default(Text("Gaussian Blur")) {
                        currentFilterName = "Gaussian Blur"
                        self.setFilter(CIFilter.gaussianBlur())
                    },
                    .default(Text("Pixellate")) {
                        currentFilterName = "Pixellate"
                        self.setFilter(CIFilter.pixellate())
                        
                    },
                    .default(Text("Sepia Tone")) {
                        currentFilterName = "Sepia Tone"
                        self.setFilter(CIFilter.sepiaTone())
                        
                    },
                    .default(Text("Unsharp Mask")) {
                        currentFilterName = "Unsharp Mask"
                        self.setFilter(CIFilter.unsharpMask())
                        
                    },
                    .default(Text("Vignette")) {
                        currentFilterName = "Vignette"
                        self.setFilter(CIFilter.vignette())
                        
                    },
                    .cancel()
                    
                ])
            }
            .alert(isPresented: $showErrorMessage, content: {
                Alert(title: Text("Image Error"), message: Text("There is error in image"), dismissButton: .default(Text("OK")))
            })
            
        } //: VSTACK
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
