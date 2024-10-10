import SwiftUI
#if !SKIP
import MapKit
#else
// skip.yml: implementation("com.google.maps.android:maps-compose:4.3.3")
import com.google.maps.android.compose.__
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
#endif

public struct ContentView: View {
    @AppStorage("tab") var tab = Tab.welcome
    @AppStorage("name") var name = "Skipper"
    @State var appearance = ""
    @State var isBeating = false
    
    private let latitude: Double = 48.083328
    private let longitude: Double = -1.68333

    public var body: some View {
        TabView(selection: $tab) {
            VStack(spacing: 0) {
                Text("Hello [\(name)](https://skip.tools)!")
                    .padding()
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .scaleEffect(isBeating ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isBeating)
                    .onAppear { isBeating = true }
            }
            .font(.largeTitle)
            .tabItem { Label("Welcome", systemImage: "heart.fill") }
            .tag(Tab.welcome)

            NavigationStack {
                #if !SKIP
                if #available(iOS 17.0, macOS 14.0, *) {
                    Map {
                        Marker("Test", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    .mapStyle(.imagery(elevation: .realistic))
                } else {
                    Text("requires iOS 17.0 or macOS 14.0")
                        .font(.title)
                }
                #else
                ComposeView { ctx in
                    GoogleMap(cameraPositionState: rememberCameraPositionState {
                        position = CameraPosition.fromLatLngZoom(LatLng(latitude, longitude), Float(12.0))
                    }) {
                        Marker(title: "Test", state: MarkerState(position: LatLng(latitude, longitude)))
                    }
                }
                #endif
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(Tab.home)

            NavigationStack {
                Form {
                    TextField("Name", text: $name)
                    Picker("Appearance", selection: $appearance) {
                        Text("System").tag("")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    HStack {
                        #if SKIP
                        ComposeView { ctx in // Mix in Compose code!
                            androidx.compose.material3.Text("💚", modifier: ctx.modifier)
                        }
                        #else
                        Text(verbatim: "💙")
                        #endif
                        Text("Powered by \(androidSDK != nil ? "Jetpack Compose" : "SwiftUI")")
                    }
                    .foregroundStyle(.gray)
                }
                .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(Tab.settings)
        }
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
    }
}

enum Tab : String, Hashable {
    case welcome, home, settings
}
