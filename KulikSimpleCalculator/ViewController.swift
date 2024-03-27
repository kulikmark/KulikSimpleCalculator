//
//  ViewController.swift
//  KulikSimpleCalculator
//
//  Created by Марк Кулик on 27.03.2024.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var firstOperand: Double?
    var secondOperand: Double?
    var operation: String = ""
    var hasDecimalPoint: Bool = false
    var isFirstDigit: Bool = true
    var isFirstOperandEntered: Bool = false
    var firstDigit: String?
    var displayTextField: UILabel!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)
        //        view.backgroundColor = UIColor.darkGray
        
        // Call the method to create buttons
        createButtons()
        
        
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .left // Направление свайпа (влево)
        displayTextField.addGestureRecognizer(swipeGesture)
        displayTextField.isUserInteractionEnabled = true // Включаем взаимодействие с пользователем
    }
    
    // MARK: - Helper Methods
    
    func clearDisplay() {
        displayTextField.text = "0"
        firstOperand = nil
        secondOperand = nil
        operation = ""
        hasDecimalPoint = false
        isFirstDigit = true
        isFirstOperandEntered = false
        firstDigit = nil // Сбрасываем первую цифру
        displayTextField.font = UIFont.systemFont(ofSize: 90)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // Стираем один символ
            if let currentText = displayTextField.text, !currentText.isEmpty {
                let updatedText = String(currentText.dropLast())
                displayTextField.text = updatedText.isEmpty ? "0" : updatedText
            } else {
                // Если текстовое поле пустое после стирания, установим "0"
                displayTextField.text = "0"
            }
        }
        isFirstDigit = true
        adjustFontSize()
    }
    
    func adjustFontSize() {
        guard let text = displayTextField.text else { return }
        let maxLength = 6
        let fontSize: CGFloat = text.count > maxLength ? 25 : 90 // Уменьшаем размер шрифта, если превышено количество символов
        displayTextField.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    // Добавление анимации нажатия кнопок
    @objc func buttonTouchDown(_ sender: UIButton) {
        // Сохраняем исходный цвет кнопки
        let originalColor = sender.backgroundColor
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.5) // Устанавливаем подсветку кнопки белым цветом при нажатии
        }
        // Восстанавливаем исходный цвет кнопки через небольшую задержку, чтобы подсветка была видна
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sender.backgroundColor = originalColor
        }
    }
    
    // Добавление анимации отпускания кнопок
    @objc func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(1.0) // Возвращаем исходную прозрачность фона кнопки при отпускании
        }
    }
    
    // MARK: - Button Actions
    
    @objc func buttonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        switch title {
        case "+", "-", "×", "÷":
            operationButtonTapped(sender)
        case "=":
            equalsButtonTapped()
        case "C":
            clearButtonTapped()
        case ".":
            decimalButtonTapped(sender)
        default:
            numberButtonTapped(sender)
        }
    }
    
    // MARK: - Button Actions
    
    func numberButtonTapped(_ sender: UIButton) {
        guard let digit = sender.currentTitle else { return }
        
        if let currentText = displayTextField.text, currentText.count < 23 { // Проверяем количество символов
            if isFirstDigit {
                displayTextField.text = digit // Заменяем старое значение новым
                isFirstDigit = false
            } else {
                displayTextField.text?.append(digit)
            }
        }
        adjustFontSize()
    }
    
    
    func operationButtonTapped(_ sender: UIButton) {
        if let currentText = displayTextField.text, let number = Double(currentText) {
            if firstDigit == nil {
                firstDigit = currentText // Сохраняем первую цифру
            }
            firstOperand = number
            operation = sender.currentTitle ?? ""
            isFirstDigit = true
        }
    }
    
    func equalsButtonTapped() {
        guard let currentText = displayTextField.text, let number = Double(currentText) else { return }
        
        // Устанавливаем второй операнд
        secondOperand = number
        
        var result: Double = 0
        switch operation {
        case "+":
            result = (firstOperand ?? 0) + (secondOperand ?? 0)
        case "-":
            result = (firstOperand ?? 0) - (secondOperand ?? 0)
        case "×":
            result = (firstOperand ?? 0) * (secondOperand ?? 0)
        case "÷":
            if (secondOperand ?? 0) == 0 {
                // Показываем сообщение об ошибке
                showAlert(title: "Ошибка", message: "Деление на ноль невозможно")
                return
            }
            result = (firstOperand ?? 0) / (secondOperand ?? 1)
        default:
            break
        }
        
        // Форматируем вывод результата с использованием NumberFormatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // Устанавливаем стиль форматирования
        formatter.minimumFractionDigits = 0 // Минимальное количество десятичных разрядов
        formatter.maximumFractionDigits = 2 // Максимальное количество десятичных разрядов
        formatter.decimalSeparator = "." // Устанавливаем точку в качестве разделителя десятичных знаков
        
        if let formattedResult = formatter.string(from: NSNumber(value: result)) {
            displayTextField.text = formattedResult // Отображаем отформатированный результат
        }
        
        // Сбрасываем состояние для следующей операции
        isFirstDigit = true
        adjustFontSize()
    }
    
    func clearButtonTapped() {
        clearDisplay()
    }
    
    func decimalButtonTapped(_ sender: UIButton) {
        guard let currentText = displayTextField.text else { return }
        
        // Проверяем, если текущий текст содержит только "0", заменяем его на "0."
        if currentText == "0" {
            displayTextField.text = "0."
        } else if !currentText.contains(".") && !isFirstDigit { // Добавляем точку только если она еще не добавлена и после ввода числа
            // Добавляем точку к текущему значению поля
            displayTextField.text = currentText + "."
        } else if isFirstDigit { // Если первая цифра, добавляем "0,"
            displayTextField.text = "0."
        }
        
        // После добавления десятичной точки, мы считаем, что введено уже не первое число
        isFirstDigit = false
    }
    
    
    // MARK: - Error Handling
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default
                                      , handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Method to create buttons
    
    func createButtons() {
        displayTextField = UILabel()
        displayTextField.text = "0"
        displayTextField.textColor = .white
        displayTextField.textAlignment = .right
        displayTextField.font = UIFont.systemFont(ofSize: 90)
        view.addSubview(displayTextField)
        displayTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            displayTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            displayTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            displayTextField.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let topConstantPortrait: CGFloat = 150 // Верхний отступ в портретной ориентации
        let topConstantLandscape: CGFloat = 20 // Верхний отступ в альбомной ориентации
        
        let topConstraintPortrait = displayTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstantPortrait)
        let topConstraintLandscape = displayTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstantLandscape)
        
        topConstraintPortrait.isActive = true
        topConstraintLandscape.isActive = false
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { _ in
            let isPortrait = UIDevice.current.orientation.isPortrait
            topConstraintPortrait.isActive = isPortrait
            topConstraintLandscape.isActive = !isPortrait
        }
        
        let buttonTitles = [
            ["C", "÷"],
            ["1", "2", "3", "+"],
            ["4", "5", "6", "-"],
            ["7", "8", "9", "×"],
            ["0", ".", "="]
        ]
        
        let spacing: CGFloat = 0
        let margin: CGFloat = 0
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: displayTextField.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: margin),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        for row in buttonTitles {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fill
            rowStackView.spacing = spacing
            stackView.addArrangedSubview(rowStackView)
            
            for title in row {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
                button.backgroundColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00)
                button.setTitleColor(UIColor.white, for: .normal)
                button.layer.borderWidth = 0.5 // Добавляем границу кнопке
                button.layer.borderColor = UIColor.black.cgColor // Устанавливаем черный цвет границы
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
                button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
                
                switch title {
                case "C":
                    button.widthAnchor.constraint(equalTo: rowStackView.widthAnchor, multiplier: 0.75, constant: -spacing).isActive = true
                    button.backgroundColor = UIColor.systemOrange
                case "0":
                    button.widthAnchor.constraint(equalTo: rowStackView.widthAnchor, multiplier: 0.5, constant: -spacing).isActive = true
                default:
                    button.widthAnchor.constraint(equalTo: rowStackView.widthAnchor, multiplier: 0.25, constant: -spacing).isActive = true
                }
                
                if ["÷", "=", "+", "-", "×"].contains(title) {
                    button.backgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.00)
                }
            }
        }
    }
}
