import Foundation

enum MapboxConfig {
    static var accessToken: String {
        if let token = Bundle.main.infoDictionary?["MAPBOX_ACCESS_TOKEN"] as? String,
           !token.isEmpty {
            return token
        }
        // Fallback：直接使用当前提供的 Access Token，方便开发调试
        return "pk.eyJ1IjoiZHpob3UyMCIsImEiOiJjbWVoNG9idTIwNDA5Mm1xMjh3anVuaTQ3In0.sMR_cnAr5puOOz51xtuVeA"
    }
}
