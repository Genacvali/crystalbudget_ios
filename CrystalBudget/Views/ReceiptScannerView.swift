import SwiftUI
import VisionKit
import Vision

struct ReceiptScannerView: UIViewControllerRepresentable {
    let onReceiptScanned: (ReceiptData) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ReceiptScannerView
        
        init(_ parent: ReceiptScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                return
            }
            
            // Process the first page
            let image = scan.imageOfPage(at: 0)
            processReceiptImage(image) { receiptData in
                DispatchQueue.main.async {
                    self.parent.onReceiptScanned(receiptData)
                    controller.dismiss(animated: true)
                }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera error: \(error)")
            controller.dismiss(animated: true)
        }
        
        private func processReceiptImage(_ image: UIImage, completion: @escaping (ReceiptData) -> Void) {
            guard let cgImage = image.cgImage else {
                completion(ReceiptData(amount: 0, category: "Другое", description: "Не удалось обработать изображение", date: Date()))
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(ReceiptData(amount: 0, category: "Другое", description: "Не удалось распознать текст", date: Date()))
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                let receiptData = self.parseReceiptText(recognizedText)
                completion(receiptData)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("Error performing text recognition: \(error)")
                completion(ReceiptData(amount: 0, category: "Другое", description: "Ошибка распознавания", date: Date()))
            }
        }
        
        private func parseReceiptText(_ text: String) -> ReceiptData {
            // Simple receipt parsing logic
            let lines = text.components(separatedBy: .newlines)
            
            var amount: Double = 0
            var category = "Другое"
            var description = "Чек"
            var date = Date()
            
            // Look for amount patterns
            let amountPatterns = [
                "\\d+[.,]\\d{2}\\s*₽",
                "\\d+[.,]\\d{2}\\s*руб",
                "\\d+[.,]\\d{2}\\s*р",
                "\\d+[.,]\\d{2}"
            ]
            
            for line in lines {
                for pattern in amountPatterns {
                    if let range = line.range(of: pattern, options: .regularExpression) {
                        let amountString = String(line[range])
                            .replacingOccurrences(of: "₽", with: "")
                            .replacingOccurrences(of: "руб", with: "")
                            .replacingOccurrences(of: "р", with: "")
                            .replacingOccurrences(of: ",", with: ".")
                            .trimmingCharacters(in: .whitespaces)
                        
                        if let parsedAmount = Double(amountString) {
                            amount = parsedAmount
                            break
                        }
                    }
                }
            }
            
            // Look for store name or category hints
            for line in lines {
                let lowercasedLine = line.lowercased()
                
                if lowercasedLine.contains("продукт") || lowercasedLine.contains("еда") || lowercasedLine.contains("кафе") || lowercasedLine.contains("ресторан") {
                    category = "Еда"
                    description = line.trimmingCharacters(in: .whitespaces)
                    break
                } else if lowercasedLine.contains("транспорт") || lowercasedLine.contains("такси") || lowercasedLine.contains("автобус") || lowercasedLine.contains("метро") {
                    category = "Транспорт"
                    description = line.trimmingCharacters(in: .whitespaces)
                    break
                } else if lowercasedLine.contains("магазин") || lowercasedLine.contains("покупк") || lowercasedLine.contains("одежд") {
                    category = "Покупки"
                    description = line.trimmingCharacters(in: .whitespaces)
                    break
                } else if lowercasedLine.contains("аптек") || lowercasedLine.contains("лекарств") || lowercasedLine.contains("здоровье") {
                    category = "Здоровье"
                    description = line.trimmingCharacters(in: .whitespaces)
                    break
                }
            }
            
            // Look for date
            let datePatterns = [
                "\\d{2}[./]\\d{2}[./]\\d{4}",
                "\\d{2}[./]\\d{2}[./]\\d{2}",
                "\\d{4}[./]\\d{2}[./]\\d{2}"
            ]
            
            for line in lines {
                for pattern in datePatterns {
                    if let range = line.range(of: pattern, options: .regularExpression) {
                        let dateString = String(line[range])
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        
                        if let parsedDate = formatter.date(from: dateString) {
                            date = parsedDate
                            break
                        }
                    }
                }
            }
            
            return ReceiptData(
                amount: amount,
                category: category,
                description: description.isEmpty ? "Чек" : description,
                date: date
            )
        }
    }
}

// MARK: - Live Text Scanner (iOS 16+)
@available(iOS 16.0, *)
struct LiveTextScannerView: View {
    let onTextScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Наведите камеру на чек")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Text("Используйте Live Text для сканирования чека")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Сканирование чека")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Receipt Processing View
struct ReceiptProcessingView: View {
    let receiptData: ReceiptData
    let onConfirm: (ReceiptData) -> Void
    let onEdit: (ReceiptData) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedAmount: String
    @State private var editedCategory: String
    @State private var editedDescription: String
    @State private var editedDate: Date
    
    init(receiptData: ReceiptData, onConfirm: @escaping (ReceiptData) -> Void, onEdit: @escaping (ReceiptData) -> Void) {
        self.receiptData = receiptData
        self.onConfirm = onConfirm
        self.onEdit = onEdit
        
        _editedAmount = State(initialValue: String(receiptData.amount))
        _editedCategory = State(initialValue: receiptData.category)
        _editedDescription = State(initialValue: receiptData.description)
        _editedDate = State(initialValue: receiptData.date)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Распознанные данные") {
                    HStack {
                        Text("Сумма")
                        Spacer()
                        TextField("0", text: $editedAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Категория")
                        Spacer()
                        TextField("Категория", text: $editedCategory)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Описание")
                        Spacer()
                        TextField("Описание", text: $editedDescription)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Дата", selection: $editedDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Подтвердить и добавить") {
                        let updatedData = ReceiptData(
                            amount: Double(editedAmount) ?? receiptData.amount,
                            category: editedCategory,
                            description: editedDescription,
                            date: editedDate
                        )
                        onConfirm(updatedData)
                        dismiss()
                    }
                    .disabled(editedAmount.isEmpty || Double(editedAmount) == nil)
                }
            }
            .navigationTitle("Обработка чека")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ReceiptProcessingView(
        receiptData: ReceiptData(
            amount: 1500,
            category: "Еда",
            description: "Обед в кафе",
            date: Date()
        ),
        onConfirm: { _ in },
        onEdit: { _ in }
    )
}
