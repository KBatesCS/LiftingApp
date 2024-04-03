//
//  AnalyticsView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/21/24.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @EnvironmentObject private var recordList: RecordList
    @EnvironmentObject private var routineList: RoutineList
    
    @State private var selectedDate: Date = .now
    
    var body: some View {
        ScrollView {
            VStack {
                Section {
                    CalendarView()
                } header: {
                    Text("Workout History")
                        .font(.largeTitle)
                        .frame(alignment: .topLeading)
                }
                Spacer()
            }
        }
    }
}

struct DayWrapper: Identifiable {
    let id = UUID() // Unique identifier
    let date: Date
}

struct CalendarView: View {
    @EnvironmentObject var recordList: RecordList
    
    @State var date: Date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var days: [Date] = []
    @State private var counts = [Int : Int]()
    @State private var selectedMonth = Date.now.monthInt
    @State private var selectedYear = Date.now.yearInt
    
    let months = Date.fullMonthNames
    let years = [2024]
    
    @State private var selectedDay: DayWrapper?
    var body: some View {
        VStack {
            HStack {
                Picker("", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                            .foregroundStyle(Color(.text))
                    }
                }
                .foregroundStyle(Color(.text))
                
                Picker("", selection: $selectedMonth) {
                    ForEach(months.indices, id: \.self) { index in
                        Text(months[index]).tag(index + 1)
                            .foregroundStyle(Color(.text))
                    }
                }
            }
            .buttonStyle(.bordered)
            .onChange(of: selectedYear) { _ in
                updateDate()
            }
            .onChange(of: selectedMonth) { _ in
                updateDate()
            }
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.black)
                        .foregroundStyle(Color(.text))
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { day in
                    if day.monthInt != date.monthInt {
                        Text("")
                    } else {
                        Button(action: {
                            if counts[day.dayInt] != nil {
                                selectedDay = DayWrapper(date: day)
                            }
                        }, label: {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.text))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            Color(.accent).opacity(counts[day.dayInt] != nil ? 0.9 : 0.4)
                                        )
                                )
                                .overlay(alignment: .bottomTrailing) {
                                    
                                    if let count = counts[day.dayInt] {
                                        Image(systemName: count <= 50 ? "\(count).circle.fill" : "plus.circle.fill")
                                            .foregroundColor(Color(.accent))
                                            .imageScale(.medium)
                                            .background(
                                                Color(.text)
                                                    .clipShape(.circle)
                                            )
                                            .offset(x: 5, y: 5)
                                    }
                                    
                                }
                        })
                    }
                }
            }
        }
        .padding()
        .onAppear {
            days = date.calendarDisplayDays
            setupCounts()
        }
        .onChange(of: date) { _ in
            days = date.calendarDisplayDays
            setupCounts()
        }
        .sheet(item: $selectedDay) { day in
            displayDayRecords(date: day.date)
        }
    }
    
    func updateDate() {
        date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
    }
    
    func setupCounts() {
        counts.removeAll()
        let filteredRecords = recordList.workoutRecords.filter {$0.date.yearInt == date.yearInt && $0.date.monthInt == date.monthInt}
        let mappedItems = filteredRecords.map{($0.date.dayInt, 1)}
        counts = Dictionary(mappedItems, uniquingKeysWith: +)
    }
}

struct displayDayRecords: View {
    @EnvironmentObject private var recordList: RecordList
    @State private var date: Date
    
    init(date: Date) {
        self.date = date
    }
    var body: some View {
        TabView {
            ForEach(recordList.workoutRecords) { record in
                if record.date.startOfDay == date.startOfDay {
                    singleDayRecordDisplay(record: record)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

struct singleDayRecordDisplay: View {
    @EnvironmentObject private var routineList: RoutineList
    @State var record: WorkoutRecord
    
    var body: some View {
        VStack {
            Section {
                Text("test")
            } header: {
                Text("\(getWorkoutNameFromID(workoutID: record.workoutID, routineList: routineList))")
                    .font(.largeTitle)
                    .frame(alignment: .topLeading)
                
            }
            .navigationTitle("test")
        }
    }
}

#Preview {
    AnalyticsView()
}
