//
//  PermissionsService.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation
import Combine
import AVFoundation
import CoreLocation

enum PermissionStatus {
    case notDetermined
    case granted
    case denied

    var isGranted: Bool { self == .granted }
}

enum PermissionType: CaseIterable {
    case camera
    case microphone
    case location
}

@MainActor
final class PermissionsService: NSObject, ObservableObject {
    private var locationManager: CLLocationManager?
    private var locationCompletion: ((PermissionStatus) -> Void)?

    func status(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                return .granted
            case .denied, .restricted:
                return .denied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .denied
            }
        case .microphone:
            let status = AVAudioSession.sharedInstance().recordPermission
            switch status {
            case .granted:
                return .granted
            case .denied:
                return .denied
            case .undetermined:
                return .notDetermined
            @unknown default:
                return .denied
            }
        case .location:
            let manager = CLLocationManager()
            let status: CLAuthorizationStatus
            if #available(iOS 14.0, *) {
                status = manager.authorizationStatus
            } else {
                status = CLLocationManager.authorizationStatus()
            }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                return .granted
            case .restricted, .denied:
                return .denied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .denied
            }
        }
    }

    func request(_ type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted ? .granted : .denied)
                }
            }
        case .microphone:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted ? .granted : .denied)
                }
            }
        case .location:
            locationCompletion = completion
            let manager = CLLocationManager()
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            locationManager = manager
        }
    }
}

extension PermissionsService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let completion = locationCompletion else { return }
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        locationCompletion = nil
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(.granted)
        case .denied, .restricted:
            completion(.denied)
        case .notDetermined:
            completion(.notDetermined)
        @unknown default:
            completion(.denied)
        }
    }

    @available(iOS, deprecated: 14.0)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let completion = locationCompletion else { return }
        locationCompletion = nil
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(.granted)
        case .denied, .restricted:
            completion(.denied)
        case .notDetermined:
            completion(.notDetermined)
        @unknown default:
            completion(.denied)
        }
    }
}
