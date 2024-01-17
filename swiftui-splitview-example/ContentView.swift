//
//  ContentView.swift
//  SplitView
//
//  Created by Cristian Cretu on 17.01.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var topViewHeight: CGFloat = 480
    @State private var dragState = DragState.inactive
    
    let minHeight: CGFloat = 100
    let snapThreshold: CGFloat = 200

    
    var body: some View {
        GeometryReader { geometry in
            VStack (alignment: .center, spacing: 0) {
                TopView(topViewHeight: $topViewHeight)
                    .frame(width: geometry.size.width, height: topViewHeight)
                    .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 10)
                        .scaleEffect(dragState.isDragging ? 0.8 : 1.0)
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.vertical, 10)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.dragState = .dragging(translation: gesture.translation)
                                    let dragAmount = gesture.translation.height
                                    let newHeight = max(minHeight, min(geometry.size.height - minHeight, topViewHeight + dragAmount))
                                    if newHeight != topViewHeight {
                                        topViewHeight = newHeight
                                    }
                                }
                                .onEnded { _ in
                                    self.dragState = .inactive
                                    withAnimation(.spring()) {
                                        let newHeight = topViewHeight
                                        if newHeight < minHeight + snapThreshold {
                                            topViewHeight = minHeight
                                        } else if (geometry.size.height - newHeight) < minHeight + snapThreshold {
                                            topViewHeight = geometry.size.height - minHeight
                                        }
                                    }
                                }
                        )
                    Spacer()
                }

                BottomView(topViewHeight: topViewHeight, totalHeight: geometry.size.height)
                    .frame(width: geometry.size.width, height: geometry.size.height - topViewHeight - 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            }
        }
        .ignoresSafeArea()
        .background(.black)
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct TopView: View {
    @Binding var topViewHeight: CGFloat
    let minHeight: CGFloat = 200
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if topViewHeight > minHeight {
                Text("Today's Weather")
                    .font(.title2)
                    .fontWeight(.bold)
                    .opacity(0.7)
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("San Francisco")
                        .fontWeight(.medium)
                    
                    if topViewHeight > minHeight {
                        Text("Sunny")
                            .font(.caption)
                            .opacity(0.8)
                    }
                }

                Spacer()
                
                if topViewHeight > minHeight {
                    Image(systemName: "sun.max.fill")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }

                Text("101°")
                    .font(.system(size: topViewHeight > minHeight ? 50 : 25 , weight: .bold, design: .rounded))
            }

            if topViewHeight > minHeight {
                Text("Humidity: 80%")
                    .font(.caption)
                    .opacity(0.8)
                Text("Wind: 10 mph NW")
                    .font(.caption)
                    .opacity(0.8)
                Text("Precipitation: 5%")
                    .font(.caption)
                    .opacity(0.8)
                Text("Air Quality: Moderate")
                    .font(.caption)
                    .opacity(0.8)
            }
        }
        .padding(20)
        .font(.system(size: 16, weight: .medium, design: .rounded))
    }
}

struct BottomView: View {
    var topViewHeight: CGFloat
    let minHeight: CGFloat = 200
    let totalHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Forecast")
                .font(.title2)
                .fontWeight(.bold)
                .opacity(0.7)
            
            if totalHeight - topViewHeight - 30 > minHeight {
                ForEach(0..<5) { day in
                    HStack {
                        Text(getDay(for: day))
                        Spacer()
                        Image(systemName: "sun.fill")
                            .foregroundColor(.yellow)
                        Text("7\(day + (day % 2) * 4)°")
                    }
                }

                Spacer()
                
                Text("Weather data provided by OpenWeatherMap.")
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .font(.system(size: 16, weight: .medium
                      , design: .rounded))
    }

    func getDay(for index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let day = Calendar.current.date(byAdding: .day, value: index, to: Date())!
        return dateFormatter.string(from: day)
    }
}



#Preview {
    ContentView()
}
