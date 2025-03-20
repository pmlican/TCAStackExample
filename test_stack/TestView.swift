import ComposableArchitecture
import SwiftUI

// MARK: - Models
struct UserProfile: Equatable {
    var name: String
    var email: String
}

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

// MARK: - A页面 (Profile)
@Reducer
struct ProfileReducer {
    @ObservableState
    struct State: Equatable {
        var userProfile = UserProfile(name: "", email: "")
        var settingsState = SettingsReducer.State()
        var detailState = DetailReducer.State()
        @Presents var route: Route?
    }
    
    enum Route: Equatable {
        case settings
        case detail
    }
    
    enum Action {
        case setNavigation(PresentationAction<Route>)
        case settings(SettingsReducer.Action)
        case detail(DetailReducer.Action)
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
                
            case .settings(.updateProfile(let profile)):
                state.userProfile = profile
                return .none
                
            case .settings, .detail:
                return .none
                
            case .updateProfile(let profile):
                state.userProfile = profile
                return .none
            }
        }
        
        Scope(state: \.settingsState, action: \.settings) {
            SettingsReducer()
        }
        Scope(state: \.detailState, action: \.detail) {
            DetailReducer()
        }
    }
}

struct ProfileView: View {
    @Perception.Bindable var store: StoreOf<ProfileReducer>
    
    private var routeBinding: Binding<ProfileReducer.Route?> {
          Binding(
              get: { store.route },
              set: { newValue in
                  store.send(.setNavigation(newValue.map { .presented($0) } ?? .dismiss))
              }
          )
      }
    
    var body: some View {
        NavigationStack {
            WithPerceptionTracking {
                VStack {
                    Text("Name: \(store.userProfile.name)")
                    Text("Email: \(store.userProfile.email)")
                    
                    Button("Open Settings") {
                        store.send(.setNavigation(.presented(.settings)))
                    }
                    Button("Open Detail") {
                        store.send(.setNavigation(.presented(.detail)))
                    }
                }
                .navigationTitle("Profile")
                .navigationDestination(
                    item: routeBinding
                ) { route in
                    switch route {
                    case .settings:
                        SettingsView(
                            store: store.scope(
                                state: \.settingsState,
                                action: \.settings
                            )
                        )
                    case .detail:
                        DetailView(
                            store: store.scope(
                                state: \.detailState,
                                action: \.detail
                            )
                        )
                    }
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
