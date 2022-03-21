//
//  ContentView.swift
//  BedTimeCalculatorChallengesLauKaPui
//
//  Created by Cyrus on 24/1/2022.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var cupOfCoffee = 1
    
    static var defaultWakeUpTime: Date{
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    //    @State private var alertTitle = ""
    @State private var alertMessage = ""
    //    @State private var showingAlert = false
    
    //    func DateExample() {
    //        var components = Calendar.current.dateComponents([.hour, .minute], from: Date.now)
    //        let hour = components.hour ?? 0
    //        let minute = components.minute ?? 0
    //        let date = Calendar.current.date(from: components) ?? Date.now
    //    }
    
    var footer: some View {
        Text("Most adults need 7 to 9 hours, although some people may need as few as 6 hours or as many as 10 hours of sleep each day. Older adults (ages 65 and older) need 7-8 hours of sleep each day. Women in the first 3 months of pregnancy often need several more hours of sleep than usual.")
    }
    
    var body: some View {
        
        //        NavigationView{
        Form{
            Text("BedTimeCalculator 🔢")
                .font(
                    .system(size: 25)
                        .bold()
                )
            
            Section(header: Text("Section #1")){
                Text("When will you want to wake up? ⏰").font(.headline)
                DatePicker("Please pick a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: wakeUpTime) { newValue in
                        CalculateBedTime()
                    }
                //        DatePicker("Please pick a date", selection: $wakeUpTime, in: Date.now...Date.now.addingTimeInterval(60*60*24*3))
            }
            
            Section(header: Text("Section #2")){
                Text("How many hour(s) do you want to sleep? 💤").font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    .onChange(of: sleepAmount) { newValue in
                        CalculateBedTime()
                    }
            }
            
            Section(header: Text("Section #3")){
                Text("No. of cup(s) of coffee drink? ☕️").font(.headline)
                //                Stepper(cupOfCoffee == 1 ? "1 cup" : "\(cupOfCoffee) cups", value: $cupOfCoffee, in: 1...20)
                //                Picker(cupOfCoffee == 1 ? "1 cup" : "\(cupOfCoffee) cups", selection: $cupOfCoffee){
                //                    ForEach(1...20, id: \.self) { number in
                //                        Text("\(number)")
                //                    }
                //                }.onChange(of: cupOfCoffee) { newValue in
                //                    CalculateBedTime()
                //                }
                Stepper(cupOfCoffee == 1 ? "1 cup" : "\(cupOfCoffee) cups", value: $cupOfCoffee, in: 1...20, step: 1)
                    .onChange(of: cupOfCoffee) { newValue in
                    CalculateBedTime()
                }
                //            Text("\(wakeUpTime)").padding()
                //            Text(Date.now, format: .dateTime)
                //            Text(Date.now.formatted(date: .long, time: .omitted))
            }
            
            Section(header: Text("Section #4"), footer: footer){
                Text("Time to sleep: \(alertMessage)")
            }
            
        }//.navigationTitle("BedTimeCalculator 🔢")
        //                .toolbar{Button("Calculate", action: CalculateBedTime)}
        .onAppear(perform: fetch)
        //        }.alert(alertTitle, isPresented: $showingAlert){
        //            Button("OK"){}
        //        }message:{
        //            Text(alertMessage)
        //        }
        
    }
    
    private func fetch(){
        CalculateBedTime()
    }
    
    private func CalculateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepTime(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cupOfCoffee))
            let timeToSleep = wakeUpTime - prediction.actualSleep
            //            alertTitle = "Time to Sleep"
            alertMessage = timeToSleep.formatted(date: .omitted, time: .shortened)
        }catch{
            //            alertTitle = "Error"
            alertMessage = "There is error in calculating the bed time!"
        }
        //        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
