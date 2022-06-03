//
//  ContentView.swift
//  Project_4_BetterRest
//
//  Created by KARAN  on 01/06/22.
//
import CoreML
import SwiftUI


struct ContentView: View {
    
    @State private var wakeup = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var sleepAmount = 8.0
    
    @State private var alerTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            
            Form {
                Section {
                    
                    DatePicker("Please enter a time",selection: $wakeup,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    
                }header: {
                    Text("When do you want to wake up ?")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours" , value: $sleepAmount , in: 4...12 , step: 0.25)
                    
                }
                
                Section{
                    
                    
                    Picker("Number of cups" , selection: $coffeeAmount){
                        ForEach(0..<21){ number in
                            if number == 0 {
                                Text("\(number) cup")
                            }else if number == 1 {
                                Text("\(number) cup")
                            }else {
                                Text("\(number) cups")
                            }
                        }
                    }
                    
                }header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action :calculateBedtime)
            }
            .alert(alerTitle , isPresented: $showingAlert){
                Button("OK"){ }
            }message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedtime(){
        do{
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour , .minute] , from: wakeup)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let predict = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeup - predict.actualSleep
            
            alerTitle = "Your ideal bed time is "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }catch{
            alerTitle = "Error"
            alertMessage = "There, was a error in prediction"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
