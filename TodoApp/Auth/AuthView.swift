//
//  AuthView.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import SwiftUI
import Combine
import PhotosUI

struct AuthView: View {
    // ViewModel instance injected from caller
    @ObservedObject var viewModel: AuthViewModel
    
    // New user creation state
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarData: Data?
    
    // User Switching/login state
    @State private var showPasswordSheet: Bool = false
    @State private var showCreateSheet: Bool = false
    @State private var pendingUserID: UUID?
    @State private var selectedUser: String? = ""
    @State private var enteredPassword: String = ""
    @State private var loginError: String?
    
    @State private var navigateToDashboard: Bool = false
    
    init(viewModel: AuthViewModel = AuthViewModel()) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choose an account")
                        .font(.title2.bold())
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 24)], spacing: 24) {
                        ForEach(viewModel.users, id: \.id) { user in
                            VStack(spacing: 8) {
                                ZStack {
                                    avatarView(for: user)
                                        .frame(width: 88, height: 88)
                                        .clipShape(Circle())
                                    
                                    if viewModel.currentUser?.id == user.id {
                                        Circle()
                                            .stroke(Color.green, lineWidth: 4)
                                            .frame(width: 92, height: 92)
                                    }
                                }
                                
                                Text(user.username)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .frame(maxWidth: 88)
                            }
                            .frame(width: 100)
                            .contentShape(Rectangle())
                            .onTapGesture { selectUser(user) }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteUser(user)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        // Create new user tile
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                Image(systemName: "plus")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 88, height: 88)
                            
                            Text("New")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { showCreateSheet = true }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("Accounts")
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task { await loadAvatar(from: newValue) }
        }
        .sheet(isPresented: $showPasswordSheet) {
            passwordSheet
        }
        .sheet(isPresented: $showCreateSheet) { createUserSheet }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $navigateToDashboard) {
            DashboardView(viewModel: DashboardViewModel(service: CoreDataToDoService(), permissionService: LocationPermissionService(), weatherService: WeatherAPIService()), currentUser: viewModel.currentUser!)
        }
    }
    
    private var passwordSheet: some View {
        NavigationStack {
            Form {
                SecureField("Password", text: $enteredPassword)
                if let loginError {
                    Text(loginError).foregroundStyle(.red)
                }
            }
            .navigationTitle("Welcome \(selectedUser ?? "")") // TODO: Fix the username issue
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showPasswordSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Login") { confirmSwitch() }
                        .disabled(enteredPassword.isEmpty)
                }
            }
        }
        .presentationDetents([.fraction(0.30)])
    }
    
    private var createUserSheet: some View {
        NavigationStack {
            Form {
                
                Section {
                    HStack(alignment: .center) {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            if let avatarData, let image = image(from: avatarData) {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    .shadow(radius: 4)
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer()
                    }
                    TextField("Username", text: $newUsername)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
            }
            .navigationTitle("Create User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createNewUser() }
                        .disabled(!canCreate)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func avatarView(for user: User) -> some View {
        Group {
            if let data = user.avatarData, let image = image(from: data) {
                image.resizable().scaledToFill()
            } else {
                ZStack {
                    Circle().fill(Color.gray.opacity(0.2))
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .padding(2)
                }
            }
        }
    }
}

// MARK: User Helpers
extension AuthView {
    private func getSelectedUser(_ id: UUID?) -> User? {
        guard let id = id else { return nil }
        return viewModel.users.first { $0.id == id }
    }
    
    private var canCreate: Bool {
        !newUsername.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    private func createNewUser() {
        let data = avatarData
        if !newPassword.isEmpty {
            viewModel.createUser(username: newUsername, avatarData: data, password: newPassword)
        } else {
            // TODO: - handle else logic
            //viewModel.createUser(username: newUsername, avatarData: data)
        }
        showCreateSheet = false
        // reset
        newUsername = ""
        newPassword = ""
        confirmPassword = ""
        selectedPhoto = nil
        avatarData = nil
    }
    
    private func selectUser(_ user: User) {
        let targetID = user.id
        pendingUserID = targetID
        selectedUser = getSelectedUser(pendingUserID)?.username
        enteredPassword = ""
        loginError = nil
        showPasswordSheet = true
    }
    
    private func confirmSwitch() {
        guard let id = pendingUserID else { return }
        viewModel.requestSwitch(to: id)
        let ok = viewModel.confirmSwitch(to: id, password: enteredPassword)
        if ok {
            navigateToDashboard = true
            showPasswordSheet = false
        } else {
            loginError = "Incorrect password. Try again."
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let user = viewModel.users[index]
            viewModel.deleteUser(user)
        }
    }
}

// MARK: - Image helpers
extension AuthView {
    private func image(from data: Data) -> Image? {
        if let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        return nil
    }
    
    // The project referenced a helper named `resizeImageData`; provide a local implementation.
    // Resize to a maximum dimension while preserving aspect ratio, then JPEG encode.
    private func resizeImageData(_ data: Data, maxDimension: CGFloat = 256, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return data }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
        
    }
    
    private func loadAvatar(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.avatarData = resizeImageData(data)
        }
    }
}
#Preview {
    AuthView(viewModel: AuthViewModel(service: MockAuthService()))
}
