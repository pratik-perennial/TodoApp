//
//  DashboardView.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import SwiftUI
import Combine
import CoreLocation

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    let currentUser: User
    
    @State private var selectedFilter: ToDoFilter = .upcoming
    @State private var editingToDo: ToDoItem? = nil
    @State private var showingEditSheet = false
    
    // State to hold current date/time, updates every second
    @State private var currentDate = Date()
    @StateObject private var locationFetcher = LocationFetcher()
    @State private var didRequestLocationOnce = false
    @State private var didLoadWeatherFromLocation = false
    
    // Timer publisher
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var filteredToDos: [ToDoItem] {
        let now = Date()
        switch selectedFilter {
        case .upcoming:
            return viewModel.todos.filter { !$0.isCompleted && $0.date >= now }
                .sorted { $0.date < $1.date }
        case .past:
            return viewModel.todos.filter { !$0.isCompleted && $0.date < now }
                .sorted { $0.date > $1.date }
        case .completed:
            return viewModel.todos.filter { $0.isCompleted }
                .sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                VStack {
                    
                    HStack {
                        Text("Hello, \(currentUser.username)")
                            .font(Font.title.bold())
                            .padding()
                        Spacer()
                        VStack(alignment: .trailing){
                            Text(currentDate, style: .date)
                                .font(.subheadline.bold())
                            
                            Text(currentDate, style: .time)
                                .font(.title3.monospacedDigit())
                                .onReceive(timer) { input in
                                    currentDate = input
                                }
                        }.padding()
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    
                    if let weather = viewModel.currentWeather {
                        CurrentWeatherView(weather: weather)
                    }
                    
                    List {
                        ForEach(filteredToDos) { todo in
                            Button {
                                editingToDo = todo
                                showingEditSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? .green : .secondary)
                                    VStack(alignment: .leading) {
                                        Text(todo.title)
                                            .font(.headline)
                                            .strikethrough(todo.isCompleted)
                                        if let notes = todo.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text(todo.date, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteToDos)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            EditButton()
                        }
                        
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Menu {
                                ForEach(ToDoFilter.allCases) { filter in
                                    Button(action: { selectedFilter = filter }) {
                                        Label(filter.rawValue, systemImage: selectedFilter == filter ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                                    .font(.title3)
                            }
                        }
                    }
                    .sheet(isPresented: $showingEditSheet) {
                        if let todo = self.editingToDo {
                            ToDoEditView(todo: todo,
                                         onSave: { todo in
                                Task {
                                    if viewModel.todos.contains(where: { $0.id == todo.id }) {
                                        await viewModel.updateTodo(todo: todo)
                                    } else {
                                        await viewModel.addNewTodo(todo: todo)
                                    }
                                    showingEditSheet = false
                                }
                            }, onCancel: {
                                showingEditSheet = false
                            })
                        }
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            
            // Floating Action Button
            Button {
                self.editingToDo = ToDoItem(title: "", date: Date())
                showingEditSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
            
            // Show Snackbar at bottom when permission is denied or restricted
            VStack {
                Spacer()
                if viewModel.locationStatus == .denied || viewModel.locationStatus == .restricted {
                    Snackbar(message: "Location permission not granted. Click here to enable it in Settings.")
                        .zIndex(1)
                        .padding(.bottom, 75)
                        .onTapGesture {
                            AppUtils.openAppSettings()
                        }
                }
            }
            .animation(.easeInOut, value: viewModel.locationStatus)
        }
        .onAppear {
            viewModel.requestLocationPermission()
            // If already authorized, immediately request a one-time location
            if viewModel.locationStatus == .authorizedAlways || viewModel.locationStatus == .authorizedWhenInUse {
                locationFetcher.requestLocation()
                didRequestLocationOnce = true
            }
        }
        .onChange(of: viewModel.locationStatus) { _, newStatus in
            if (newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse) && !didRequestLocationOnce {
                locationFetcher.requestLocation()
                didRequestLocationOnce = true
            }
        }
        .onReceive(locationFetcher.$lastLocation.compactMap { $0 }) { coordinate in
            if !didLoadWeatherFromLocation {
                viewModel.loadWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
                didLoadWeatherFromLocation = true
            }
        }
    }
    
    private func deleteToDos(at offsets: IndexSet) {
        Task {
            for offset in offsets {
                await viewModel.deleteTodo(todo: filteredToDos[offset])
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(service: MockToDoService(), permissionService: LocationPermissionService(), weatherService: WeatherAPIService()), currentUser: User(username: "Test", avatarData: nil))
}

enum ToDoFilter: String, CaseIterable, Identifiable {
    case upcoming = "Upcoming"
    case past = "Past"
    case completed = "Completed"
    
    var id: String { rawValue }
}

final class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // You could add logging here if desired
    }
}

