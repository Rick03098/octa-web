//
//  AppCoordinator.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

/// 負責根據當前應用狀態生成根視圖的協調器。
/// 目前包含登入、名字與生日三個步驟，後續可擴展為完整的 13 步流程。
@MainActor
final class AppCoordinator: ObservableObject {
    enum OnboardingStep {
        case login
        case name
        case birthday
        case birthTime
        case birthLocation
        case gender
        case baziResult
        case permissions
        case captureTutorial
        case captureCamera
        case captureComplete
        case orientationCapture
        case environmentPreview
        case environmentReport
        case chat
        case selfCenter
        case mainDashboard
    }

    let sessionStore: SessionStore
    let onboardingFlow: UserOnboardingFlowState
    let backendStatus: BackendConnectionStatus
    @Published private(set) var currentStep: OnboardingStep = .login

    private lazy var loginController: LoginController = {
        let controller = LoginController()
        controller.backendStatus = backendStatus
        controller.onCreateAccount = { [weak self] in
            self?.goToName()
        }
        controller.onGoogleLogin = { [weak self] in
            self?.goToName()
        }
        controller.onMemberLogin = { [weak self] in
            self?.goToName()
        }
        return controller
    }()
    private lazy var nameController: NameEntryController = {
        let controller = NameEntryController(
            useCase: NameEntryUseCase(flowState: onboardingFlow)
        )
        controller.onContinue = { [weak self] in
            self?.goToBirthday()
        }
        controller.onBack = { [weak self] in
            self?.currentStep = .login
        }
        return controller
    }()
    private var birthdayController: BirthdayInputController?
    private var birthTimeController: BirthTimeInputController?
    private var birthLocationController: BirthLocationInputController?
    private var genderController: GenderSelectionController?
    private var baziResultController: BaziResultController?
    private var permissionsController: PermissionsController?
    private let permissionsService = PermissionsService()
    private var captureTutorialController: CaptureTutorialController?
    private var captureCameraController: CaptureCameraController?
    private var captureCompleteController: CaptureCompleteController?
    private var orientationController: OrientationCaptureController?
    private var environmentPreviewController: EnvironmentPreviewController?
    private var environmentReportController: EnvironmentReportController?
    private var selfCenterController: SelfCenterController?
    private var mainController: MainDashboardController?

    init(
        sessionStore: SessionStore,
        onboardingFlow: UserOnboardingFlowState,
        backendStatus: BackendConnectionStatus
    ) {
        self.sessionStore = sessionStore
        self.onboardingFlow = onboardingFlow
        self.backendStatus = backendStatus
    }

    /// 返回當前需要展示的根視圖。
    func makeRootView() -> AnyView {
        switch currentStep {
        case .login:
            return AnyView(
                LoginView(controller: loginController)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .name:
            return AnyView(
                NameEntryView(controller: nameController)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .birthday:
            let controller = makeBirthdayController()
            return AnyView(
                BirthdayInputView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .birthTime:
            let controller = makeBirthTimeController()
            return AnyView(
                BirthTimeInputView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .birthLocation:
            let controller = makeBirthLocationController()
            return AnyView(
                BirthLocationInputView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .gender:
            let controller = makeGenderController()
            return AnyView(
                GenderSelectionView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .baziResult:
            let controller = makeBaziResultController()
            return AnyView(
                BaziResultView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .permissions:
            let controller = makePermissionsController()
            return AnyView(
                PermissionsView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .captureTutorial:
            let controller = makeCaptureTutorialController()
            return AnyView(
                CaptureTutorialView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .captureCamera:
            let controller = makeCaptureCameraController()
            return AnyView(
                CaptureCameraView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .captureComplete:
            let controller = makeCaptureCompleteController()
            return AnyView(
                CaptureCompleteView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .orientationCapture:
            let controller = makeOrientationCaptureController()
            return AnyView(
                OrientationCaptureView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .environmentPreview:
            let controller = makeEnvironmentPreviewController()
            return AnyView(
                EnvironmentPreviewView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .environmentReport:
            let controller = makeEnvironmentReportController()
            return AnyView(
                EnvironmentReportView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .chat:
            return AnyView(
                ChatIntroView(userName: onboardingFlow.name.isEmpty ? "朋友" : onboardingFlow.name)
            )
        case .mainDashboard:
            let controller = makeMainDashboardController()
            return AnyView(
                MainDashboardView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        case .selfCenter:
            let controller = makeSelfCenterController()
            return AnyView(
                SelfCenterView(controller: controller)
                    .environmentObject(sessionStore)
                    .environmentObject(onboardingFlow)
            )
        }
    }

    private func makeBirthdayController() -> BirthdayInputController {
        if let controller = birthdayController {
            return controller
        }
        let controller = BirthdayInputController(
            useCase: BirthdayInputUseCase(flowState: onboardingFlow),
            initialDate: onboardingFlow.birthDate
        )
        controller.onBack = { [weak self] in
            self?.currentStep = .name
        }
        controller.onContinue = { [weak self] in
            self?.goToBirthTime()
        }
        birthdayController = controller
        return controller
    }

    private func makeBirthTimeController() -> BirthTimeInputController {
        if let controller = birthTimeController {
            return controller
        }
        let controller = BirthTimeInputController(
            useCase: BirthTimeInputUseCase(flowState: onboardingFlow),
            initialValue: onboardingFlow.birthTime
        )
        controller.onBack = { [weak self] in
            self?.currentStep = .birthday
        }
        controller.onContinue = { [weak self] in
            self?.goToBirthLocation()
        }
        birthTimeController = controller
        return controller
    }

    private func makeBirthLocationController() -> BirthLocationInputController {
        if let controller = birthLocationController {
            return controller
        }
        let controller = BirthLocationInputController(
            useCase: BirthLocationInputUseCase(flowState: onboardingFlow),
            initialValue: onboardingFlow.birthLocation
        )
        controller.onBack = { [weak self] in
            self?.currentStep = .birthTime
        }
        controller.onContinue = { [weak self] in
            self?.goToGender()
        }
        birthLocationController = controller
        return controller
    }

    private func makeGenderController() -> GenderSelectionController {
        if let controller = genderController {
            return controller
        }
        let controller = GenderSelectionController(
            useCase: GenderSelectionUseCase(flowState: onboardingFlow),
            initial: onboardingFlow.gender
        )
        controller.onBack = { [weak self] in
            self?.currentStep = .birthLocation
        }
        controller.onContinue = { [weak self] in
            self?.goToBaziResult()
        }
        genderController = controller
        return controller
    }

    private func makeBaziResultController() -> BaziResultController {
        if let controller = baziResultController {
            return controller
        }
        let controller = BaziResultController(
            useCase: BaziResultUseCase(backendStatus: backendStatus),
            flowState: onboardingFlow
        )
        controller.onBack = { [weak self] in
            self?.currentStep = .gender
        }
        controller.onContinue = { [weak self] in
            self?.handleBaziResultContinue()
        }
        baziResultController = controller
        return controller
    }

    private func makePermissionsController() -> PermissionsController {
        if let controller = permissionsController {
            return controller
        }
        let controller = PermissionsController(service: permissionsService)
        controller.onBack = { [weak self] in
            self?.currentStep = .baziResult
        }
        controller.onContinue = { [weak self] in
            self?.handlePermissionsContinue()
        }
        permissionsController = controller
        return controller
    }

    private func goToName() {
        currentStep = .name
    }

    private func goToBirthday() {
        currentStep = .birthday
    }

    private func goToBirthTime() {
        currentStep = .birthTime
    }

    private func goToBirthLocation() {
        currentStep = .birthLocation
    }

    private func goToGender() {
        currentStep = .gender
    }

    private func goToBaziResult() {
        currentStep = .baziResult
    }

    private func handleBaziResultContinue() {
        goToPermissions()
    }

    private func goToPermissions() {
        currentStep = .permissions
    }

    private func handlePermissionsContinue() {
        goToCaptureTutorial()
    }

    private func makeMainDashboardController() -> MainDashboardController {
        if let controller = mainController {
            return controller
        }
        let controller = MainDashboardController(flowState: onboardingFlow)
        controller.onAddEnvironment = { [weak self] in
            self?.goToCaptureTutorial()
        }
        controller.onSelfSelected = { [weak self] in
            self?.goToSelfCenter()
        }
        mainController = controller
        return controller
    }

    private func goToMainDashboard() {
        currentStep = .mainDashboard
    }

    private func makeSelfCenterController() -> SelfCenterController {
        if let controller = selfCenterController {
            return controller
        }
        let controller = SelfCenterController()
        controller.onEnvironmentTab = { [weak self] in
            self?.goToMainDashboard()
        }
        controller.onLogout = {
            // TODO: 登出流程
        }
        selfCenterController = controller
        return controller
    }

    private func goToSelfCenter() {
        currentStep = .selfCenter
    }

    private func makeCaptureTutorialController() -> CaptureTutorialController {
        if let controller = captureTutorialController {
            return controller
        }
        let controller = CaptureTutorialController()
        controller.onBack = { [weak self] in
            self?.goToMainDashboard()
        }
        controller.onContinue = { [weak self] in
            self?.goToCaptureCamera()
        }
        captureTutorialController = controller
        return controller
    }

    private func goToCaptureTutorial() {
        currentStep = .captureTutorial
    }

    private func makeCaptureCameraController() -> CaptureCameraController {
        if let controller = captureCameraController {
            return controller
        }
        let controller = CaptureCameraController()
        controller.onBack = { [weak self] in
            self?.goToCaptureTutorial()
        }
        controller.onCompleted = { [weak self] in
            self?.goToCaptureComplete()
        }
        captureCameraController = controller
        return controller
    }

    private func goToCaptureCamera() {
        currentStep = .captureCamera
    }

    private func makeCaptureCompleteController() -> CaptureCompleteController {
        if let controller = captureCompleteController {
            return controller
        }
        let controller = CaptureCompleteController()
        controller.onFinished = { [weak self] in
            self?.goToOrientationCapture()
        }
        captureCompleteController = controller
        return controller
    }

    private func goToCaptureComplete() {
        currentStep = .captureComplete
    }

    private func makeOrientationCaptureController() -> OrientationCaptureController {
        if let controller = orientationController {
            return controller
        }
        let controller = OrientationCaptureController(flowState: onboardingFlow)
        controller.onFinished = { [weak self] in
            self?.goToEnvironmentPreview()
        }
        orientationController = controller
        return controller
    }

    private func goToOrientationCapture() {
        currentStep = .orientationCapture
    }

    private func makeEnvironmentPreviewController() -> EnvironmentPreviewController {
        if let controller = environmentPreviewController {
            return controller
        }
        let controller = EnvironmentPreviewController()
        controller.onContinue = { [weak self] in
            self?.goToEnvironmentReport()
        }
        environmentPreviewController = controller
        return controller
    }

    private func goToEnvironmentPreview() {
        currentStep = .environmentPreview
    }

    private func makeEnvironmentReportController() -> EnvironmentReportController {
        if let controller = environmentReportController {
            return controller
        }
        let controller = EnvironmentReportController(useCase: EnvironmentReportUseCase(backendStatus: backendStatus))
        controller.onBack = { [weak self] in
            self?.goToEnvironmentPreview()
        }
        controller.onChat = { [weak self] in
            self?.goToChat()
        }
        environmentReportController = controller
        return controller
    }

    private func goToEnvironmentReport() {
        currentStep = .environmentReport
    }

    private func goToChat() {
        currentStep = .chat
    }

    func resetFlow() {
        currentStep = .login
        onboardingFlow.reset()
        birthdayController = nil
        birthTimeController = nil
        birthLocationController = nil
        genderController = nil
        baziResultController = nil
        permissionsController = nil
        captureTutorialController = nil
        captureCameraController = nil
        captureCompleteController = nil
        orientationController = nil
        environmentPreviewController = nil
        environmentReportController = nil
        selfCenterController = nil
        mainController = nil
    }
}
