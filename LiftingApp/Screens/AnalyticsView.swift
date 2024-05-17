//
//  AnalyticsView.swift
//  LiftingApp
//
//  Created by Kevin Bates on 3/21/24.
//

import SwiftUI
import CoreData

struct AnalyticsView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    
    @State private var selectedDate: Date = .now
    @State private var selectedMonth: Int = Date.now.monthInt
    @State private var selectedYear: Int = Date.now.yearInt
    
    var body: some View {
        ScrollView {
            VStack {
                Section {
                    SwipeableCalendarView(workoutRecords: workoutRecords, selectedMonth: $selectedMonth, selectedYear: $selectedYear)
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

struct SwipeableCalendarView: View {
    private let months = Date.fullMonthNames
    private let years: [Int]
    private let maxYear: Int
    
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    
    @State var selectedTab: Int = 2
    
    @State var testTab: Int
    
    @State private var workoutRecords: FetchedResults<CDWorkoutRecord>
    
    init(workoutRecords: FetchedResults<CDWorkoutRecord>, selectedMonth: Binding<Int>, selectedYear: Binding<Int>) {
        self._workoutRecords = State(initialValue: workoutRecords)
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
        self.testTab = ((selectedYear.wrappedValue - 2024) * 12) + selectedMonth.wrappedValue
        self.maxYear = Date().yearInt + 1
        self.years = Array(2024...maxYear)
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                            .foregroundStyle(Color(.text))
                    }
                }
                .onChange(of: selectedYear) { _ in
                    self.testTab = ((selectedYear - 2024) * 12) + selectedMonth
                }
                .foregroundStyle(Color(.text))
                
                Picker("", selection: $selectedMonth) {
                    ForEach(months.indices, id: \.self) { index in
                        Text(months[index]).tag(index + 1)
                            .foregroundStyle(Color(.text))
                    }
                }
                .onChange(of: selectedMonth) { _ in
                    self.testTab = ((selectedYear - 2024) * 12) + selectedMonth
                }
            }
            .onAppear {
                
            }
            .buttonStyle(.bordered)
            
            TabView(selection: $testTab) {
                ForEach((1)...(((maxYear - 2024) + 1) * 12), id: \.self) { i in
                    let monthAndYear = getMonthYearSinceDec2023(monthsSince: i)
                    let month = monthAndYear[0]
                    let year = monthAndYear[1]
                    CalendarView(workoutRecords: workoutRecords, selectedMonth: month, selectedYear: year)
                }
            }
            .onChange(of: testTab) { _ in
                let monthAndYear = getMonthYearSinceDec2023(monthsSince: testTab)
                self.selectedMonth = monthAndYear[0]
                self.selectedYear = monthAndYear[1]
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 400, height: 400)
        }
    }
    
    func getMonthYearSinceDec2023(monthsSince: Int) -> [Int]{
        let year = Int((monthsSince - 1) / 12) + 2024
        let month = (((monthsSince - 1)  % 12)) + 1
        
        return [month, year]
    }
    
    func getPreviousMonthYear(year: Int, month: Int) ->[Int] {
        var nextMonth = month - 1
        var nextYear = year
        if nextMonth <= 0 {
            nextMonth = 1
            nextYear -= 1
        }
        
        return [nextYear, nextMonth]
    }
    
    func getNextMonthYear(year: Int, month: Int) ->[Int] {
        var nextMonth = month + 1
        var nextYear = year
        if nextMonth >= 13 {
            nextMonth = 1
            nextYear += 1
        }
        
        return [nextYear, nextMonth]
    }
}



struct CalendarView: View {
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var days: [Date] = []
    @State private var counts = [Int: Int]()
    @State private var selectedDay: DayWrapper?
    var selectedMonth: Int
    var selectedYear: Int
    
    init(workoutRecords: FetchedResults<CDWorkoutRecord>, selectedMonth: Int, selectedYear: Int) {
        self.workoutRecords = workoutRecords
        self.selectedMonth = selectedMonth
        self.selectedYear = selectedYear
    }
    
    var body: some View {
        VStack {
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
                    if day.monthInt != selectedMonth {
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
                                        if count > 1 {
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
                                }
                        })
                    }
                }
            }
        }
        .padding()
        .onAppear {
            updateDate()
            setupCounts()
        }
        .onChange(of: selectedYear) { _ in
            updateDate()
            setupCounts()
        }
        .onChange(of: selectedMonth) { _ in
            updateDate()
            setupCounts()
        }
        .sheet(item: $selectedDay) { day in
            DisplayDayRecords(workoutRecords: workoutRecords, date: day.date)
        }
    }
    
    private func updateDate() {
        self.days = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!.calendarDisplayDays
    }
    
    private func setupCounts() {
        counts.removeAll()
        let filteredRecords = workoutRecords.filter { $0.date.yearInt == self.selectedYear && $0.date.monthInt == self.selectedMonth }
        let mappedItems = filteredRecords.map { ($0.date.dayInt, 1) }
        counts = Dictionary(mappedItems, uniquingKeysWith: +)
    }
}


struct DisplayDayRecords: View {
    //@EnvironmentObject private var recordList: RecordList
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    @State var date: Date
    
    var body: some View {
        TabView {
            ForEach(workoutRecords) { record in
                if record.date.startOfDay == date.startOfDay {
                    SingleDayRecordDisplay(record: record)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

struct SingleDayRecordDisplay: View {
    //@EnvironmentObject private var routineList: RoutineList
    var record: CDWorkoutRecord
    
    var totalWeight: Double {
        var weight = 0.0
        for exerciseRecord in record.exercises {
            for set in exerciseRecord.sets {
                if set.completed {
                    // Calculate total weight based on reps and weight
                    weight += Double(set.reps) * set.weight
                    // TODO weight a pound conversions
                }
            }
        }
        return weight
    }
    
    var body: some View {
        VStack {
            Section {
                List {
                    ForEach(record.exercises) { exerciseRecord in
                        VStack {
                            Text(exerciseRecord.exercise.name)
                            ForEach(exerciseRecord.sets) { set in
                                HStack {
                                    Text(String(set.completed))
                                    Spacer()
                                    Text(String(set.weight))
                                }
                            }
                        }
                    }
                    
                    Text("Total Weight: \(String(format: "%.0f", totalWeight)) LBS") //TODO choose default weight measurement
                }
            } header: {
                HStack {
                    //Text("\(getWorkoutNameFromID(workoutID: record.workoutID, routineList: routineList))")
                    Text("Temp Title")
                        .font(.largeTitle)
                        .frame(alignment: .leading) // Align text to leading
                    Spacer()
                }
            }
            .navigationTitle("Test")
            
            Spacer()
        }
    }
    
}

#Preview {
    AnalyticsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    
}
