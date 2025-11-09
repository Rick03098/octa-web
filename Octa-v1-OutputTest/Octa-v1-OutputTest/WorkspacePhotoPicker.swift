import SwiftUI
import PhotosUI

struct WorkspacePhotoPicker: View {
    @Binding var imageData: Data?
    @Binding var imageMimeType: String

    @State private var isPresentingPicker = false
    @State private var isShowingSettingsAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            preview

            HStack(spacing: 16) {
                Button {
                    checkAndPresentPicker()
                } label: {
                    Label("选择照片", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Label("打开相册权限", systemImage: "gearshape")
                }
                .buttonStyle(.bordered)
                .opacity(shouldShowSettingsButton ? 1 : 0)
                .frame(height: shouldShowSettingsButton ? nil : 0)
            }
            .labelStyle(.titleAndIcon)
        }
        .sheet(isPresented: $isPresentingPicker) {
            PhotoPickerController(imageData: $imageData, imageMimeType: $imageMimeType)
        }
        .alert("无法访问照片", isPresented: $isShowingSettingsAlert) {
            Button("确定", role: .cancel) { }
            Button("前往设置") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        } message: {
            Text("请在系统设置中为本应用开启照片访问权限。")
        }
    }

    private var preview: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3))
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                            Text("尚未上传工位照片")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    )
            }
        }
    }

    private func checkAndPresentPicker() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isPresentingPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        isPresentingPicker = true
                    } else {
                        isShowingSettingsAlert = true
                    }
                }
            }
        default:
            isShowingSettingsAlert = true
        }
    }

    private var shouldShowSettingsButton: Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .denied, .restricted: return true
        default: return false
        }
    }
}

private struct PhotoPickerController: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Binding var imageMimeType: String

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(imageData: $imageData, imageMimeType: $imageMimeType)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var imageData: Data?
        @Binding var imageMimeType: String

        init(imageData: Binding<Data?>, imageMimeType: Binding<String>) {
            _imageData = imageData
            _imageMimeType = imageMimeType
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage,
                       let data = image.jpegData(compressionQuality: 0.9) {
                        DispatchQueue.main.async {
                            self.imageData = data
                            self.imageMimeType = "image/jpeg"
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier("public.jpeg") {
                provider.loadDataRepresentation(forTypeIdentifier: "public.jpeg") { data, _ in
                    if let data {
                        DispatchQueue.main.async {
                            self.imageData = data
                            self.imageMimeType = "image/jpeg"
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WorkspacePhotoPicker(imageData: .constant(nil), imageMimeType: .constant("image/jpeg"))
        .padding()
}
