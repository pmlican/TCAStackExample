import ComposableArchitecture
import SwiftUI

// MARK: - Models
struct UserProfile: Equatable {
    var name: String
    var email: String
}



// MARK: - A页面 (Profile)
@Reducer
struct ProfileReducer {
    @ObservableState
    struct State: Equatable {
        var userProfile = UserProfile(name: "", email: "")
        var settingsState = SettingsReducer.State()
        var detailState = DetailReducer.State()
        var path = StackState<Path.State>()
    }
    
    @Reducer
    enum Path {
        case settings(SettingsReducer)
        case detail(DetailReducer)
    }
    
    enum Action {
        case settings(SettingsReducer.Action)
        case detail(DetailReducer.Action)
        case path(StackActionOf<Path>)
        case toSetting
        case toDetail
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .toSetting:
                state.path.append(.settings(SettingsReducer.State()))
                return .none
                
            case .toDetail:
                state.path.append(.detail(DetailReducer.State()))
                return .none
                
            case .settings(.updateProfile(let profile)):
                state.userProfile = profile
                return .none
                
            case .settings, .detail:
                return .none

            case let .path(.element(id: _, action: .settings(.updateProfile(profile)))):
                state.userProfile = profile
                return .none
            case .path:
                return .none
            }
            
            

        }
        .forEach(\.path, action: \.path)
    }
}

extension ProfileReducer.Path.State: Equatable {}

struct ProfileView: View {
    @Perception.Bindable var store: StoreOf<ProfileReducer>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    Text("Name: \(store.userProfile.name)")
                    Text("Email: \(store.userProfile.email)")
                    
                    Button("Open Settings") {
                        store.send(.toSetting)
                    }
                    Button("Open Detail") {
                        store.send(.toDetail)
                    }
                }
                .navigationTitle("Profile")
            } destination: { store in
                switch store.case {
                case let .settings(store):
                    SettingsView(
                        store: store
                    )
                case let .detail(store):
                    DetailView(
                        store: store
                    )
                }
            }
        }
        
    }
}

// MARK: - B页面 (Settings)
@Reducer
struct SettingsReducer {
    @ObservableState
    struct State: Equatable {
        var userProfile: UserProfile = UserProfile(name: "", email: "")
        var editNameState = EditNameReducer.State()
        @Presents var route: Route?
    }
    
    enum Route {
        case editName
    }
    
    enum Action {
        case setNavigation(PresentationAction<Route>)
        case editName(EditNameReducer.Action)
        case updateProfile(UserProfile)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setNavigation(.presented(let route)):
                state.route = route
                return .none
                
            case .setNavigation(.dismiss):
                state.route = nil
                return .none
                
            case .editName(.nameUpdated(let newName)):
                var updatedProfile = state.userProfile
                updatedProfile.name = newName
                return .send(.updateProfile(updatedProfile))
                
            case .editName:
                return .none
                
            case .updateProfile(let profile):
                state.userProfile = profile
                return .none
            }
        }
        
        Scope(state: \.editNameState, action: \.editName) {
            EditNameReducer()
        }
    }
}

struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        WithPerceptionTracking {
            List {
                Section("Personal Info") {
                    Text("Name: \(store.userProfile.name)")
                    Button("Edit Name") {
                        store.send(.setNavigation(.presented(.editName)))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(item: $store.scope(state: \.route, action: \.setNavigation)) { _ in
                EditNameView(
                    store: store.scope(
                        state: \.editNameState,
                        action: \.editName
                    )
                )
            }
        }
    }
}

// MARK: - C页面 (EditName)
@Reducer
struct EditNameReducer {
    @ObservableState
    struct State: Equatable {
        var name: String = ""
    }
    
    enum Action {
        case nameChanged(String)
        case nameUpdated(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .nameChanged(name):
                state.name = name
                return .none
                
            case .nameUpdated:
                return .none
            }
        }
    }
}

struct EditNameView: View {
    @Perception.Bindable var store: StoreOf<EditNameReducer>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            Form {
                TextField("Name", text: $store.name.sending(\.nameChanged))
                
                Button("Save") {
                    store.send(.nameUpdated(store.name))
                    dismiss()
                }
            }
            .navigationTitle("Edit Name")
        }
    }
}

// MARK: - D页面 (Detail)
struct DetailView: View {
    let store: StoreOf<DetailReducer>
    var body: some View {
        VStack {
            Text("123")
        }
    }
}

@Reducer
struct DetailReducer {
    @ObservableState
    struct State: Equatable {
        
    }
    enum Action {
        case test1
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .test1:
                return .none
            }
        }
    }
}
