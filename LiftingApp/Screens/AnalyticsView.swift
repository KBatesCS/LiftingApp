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
    
    @State private var filteredRecords: [CDWorkoutRecord] = []
    
    @State private var totalWorkouts: Int = 0
    @State private var totalWeightLifted: Double = 0
    @State private var totalTimeWorkedOut: Int = 0
    @State private var averageDuration: Int = 0
    @State private var mostUsedMuscle: String = ""
    @State private var leastUsedMuscle: String = ""
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            VStack {
                Section {
                    SwipeableCalendarView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                } header: {
                    Text("Workout History")
                        .font(.largeTitle)
                        .frame(alignment: .topLeading)
                }
                Spacer()
                
                
                
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        StatisticBox(title: "Completed Workouts", content: "\(totalWorkouts)")
                        Spacer()
                        StatisticBox(title: "Weight Lifted (lbs)", content: String(format: "%.1f", totalWeightLifted))
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        let hours = totalTimeWorkedOut / 3600
                        let minutes = (totalTimeWorkedOut % 3600) / 60
                        let remainingSeconds = totalTimeWorkedOut % 60
                        StatisticBox(title: "Time Spent in Gym", content: "\(hours)h \(minutes)m \(remainingSeconds)s")
                        Spacer()

                        let avgHours = averageDuration / 3600
                        let avgMinutes = (averageDuration % 3600) / 60
                        let avgSeconds = averageDuration % 60
                        StatisticBox(title: "Average Duration", content: "\(avgHours)h \(avgMinutes)m \(avgSeconds)s")
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        StatisticBox(title: "Most Used Muscle", content: mostUsedMuscle)
                        Spacer()

                        StatisticBox(title: "Least Used Muscle", content: leastUsedMuscle)
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            self.filteredRecords = workoutRecords.filter { $0.date.yearInt == self.selectedYear && $0.date.monthInt == self.selectedMonth }
        }
        .onChange(of: selectedYear) { _ in
            self.filteredRecords = workoutRecords.filter { $0.date.yearInt == self.selectedYear && $0.date.monthInt == self.selectedMonth }
        }
        .onChange(of: selectedMonth) { _ in
            self.filteredRecords = workoutRecords.filter { $0.date.yearInt == self.selectedYear && $0.date.monthInt == self.selectedMonth }
        }
        .onChange(of: self.filteredRecords) { _ in
            self.setupAnalytics()
        }
    }
    
    func setupAnalytics() {
        totalWorkouts = filteredRecords.count
        totalWeightLifted = 0
        totalTimeWorkedOut = 0
        
        var muscleGroupCount: [Muscles: Double] = [:]
        
        muscleGroupCount[Muscles.back] = 0
        muscleGroupCount[Muscles.chest] = 0
        muscleGroupCount[Muscles.shoulder] = 0
        muscleGroupCount[Muscles.bicep] = 0
        muscleGroupCount[Muscles.tricep] = 0
        muscleGroupCount[Muscles.quad] = 0
        muscleGroupCount[Muscles.hamstring] = 0
        muscleGroupCount[Muscles.calf] = 0
        muscleGroupCount[Muscles.glute] = 0
        
        for (_, workout) in filteredRecords.enumerated() {
            totalTimeWorkedOut += workout.totalTime
            for (_, eset) in workout.exercises.enumerated() {
                for (_, set) in eset.sets.enumerated() {
                    if set.completed {
                        totalWeightLifted += set.weight * Double(set.reps)
                        for primaryMuscle in eset.exercise.primaryMusclesWorked {
                            if muscleGroupCount[primaryMuscle] != nil {
                                muscleGroupCount[primaryMuscle]! += 1
                            }
                        }
                        for secondaryMuscle in eset.exercise.secondaryMusclesWorked {
                            if muscleGroupCount[secondaryMuscle] != nil {
                                muscleGroupCount[secondaryMuscle]! += 0.5
                            }
                        }
                    }
                }
            }
        }
        
        let sortedMuscleGroupCount = muscleGroupCount.sorted { $0.value < $1.value }
        
        if let mostUsed = sortedMuscleGroupCount.last {
            self.mostUsedMuscle = "\(mostUsed.key)"
        }
        if let leastUsed = sortedMuscleGroupCount.first {
            self.leastUsedMuscle = "\(leastUsed.key)"
        }
        
        for value in sortedMuscleGroupCount {
            print("\(value.key) : \(value.value)")
        }
        if totalWorkouts == 0 {
            averageDuration = 0
        } else {
            averageDuration = totalTimeWorkedOut / totalWorkouts
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
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    
    init(selectedMonth: Binding<Int>, selectedYear: Binding<Int>) {
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
        self.testTab = ((selectedYear.wrappedValue - 2024) * 12) + selectedMonth.wrappedValue
        self.maxYear = Int(Date().yearInt) + 1
        self.years = Array(2024...maxYear)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
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
                Spacer()
            }
            .onAppear {
                
            }
            .buttonStyle(.bordered)
            
            TabView(selection: $testTab) {
                ForEach((1)...(((maxYear - 2024) + 1) * 12), id: \.self) { i in
                    let monthAndYear = getMonthYearSinceDec2023(monthsSince: i)
                    let month = monthAndYear[0]
                    let year = monthAndYear[1]
                    CalendarView(selectedMonth: month, selectedYear: year)
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
}



struct CalendarView: View {
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workoutRecords: FetchedResults<CDWorkoutRecord>
    
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var days: [Date] = []
    @State private var counts = [Int: Int]()
    @State private var selectedDay: DayWrapper?
    var selectedMonth: Int
    var selectedYear: Int
    
    init(selectedMonth: Int, selectedYear: Int) {
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
    
    @State var title: String = ""
    
    @Environment(\.managedObjectContext) var context
    
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
                        Section {
                            VStack {
                                ForEach(exerciseRecord.sets) { set in
//                                    Divider()
                                    HStack {
                                        Text(String(set.completed))
                                        Spacer()
                                        Text(String(set.weight))
                                    }
                                    .background(Color(.accent))
                                    .cornerRadius(5)
                                }
                            }
                            .listRowBackground(Color(.accent).opacity(0.80))
                        } header: {
                            Text(exerciseRecord.exercise.name)
                        }
                    }
                    
                    Text("Total Weight: \(String(format: "%.0f", totalWeight)) LBS") //TODO choose default weight measurement
                }
            } header: {
                HStack {
                    Text(self.title)
                        .font(.largeTitle)
                        .frame(alignment: .leading)
                        .padding()// Align text to leading
                    Spacer()
                }
            }
            .onAppear {
                self.title = getTitle()
            }
            
            Spacer()
        }
    }
    
    func getTitle() -> String {
        let request = CDWorkout.fetch()
        request.predicate = NSPredicate(format: "uuid_ == %@", record.workoutUUID.uuidString)
        request.fetchLimit = 1
        do {
            let workout = try context.fetch(request)
            if !workout.isEmpty {
                return workout[0].name
            }
        } catch {
            print(error)
            return ""
        }
        print("no workout found")
        return ""
    }
    
}

struct SDPreviewView: View {
    
    @FetchRequest(fetchRequest: CDWorkoutRecord.fetch())
    var workouts: FetchedResults<CDWorkoutRecord>
    @State var workoutRecord: CDWorkoutRecord? = nil
    
    init() {
        let request = CDWorkoutRecord.fetch()
        _workouts = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack {
            if let record = workoutRecord {
                SingleDayRecordDisplay(record: record)
            } else {
                Text("")
            }
        }
        .onAppear {
            workoutRecord = workouts[0]
        }
    }
}

struct SingleDayRecordPreview: PreviewProvider {
    static var previews: some View {
        return SDPreviewView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
