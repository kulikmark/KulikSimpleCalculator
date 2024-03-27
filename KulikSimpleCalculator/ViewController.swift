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
        
        displayTextField = UILabel()
        displayTextField.text = "0"
        displayTextField.textColor = .white
        displayTextField.textAlignment = .right
        displayTextField.font = UIFont.systemFont(ofSize: 90)
        view.addSubview(displayTextField)
        displayTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            displayTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 210),
            displayTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            displayTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            displayTextField.heightAnchor.constraint(equalToConstant: 100)
        ])
        
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
        let fontSize: CGFloat = text.count > maxLength ? 35 : 90 // Уменьшаем размер шрифта, если превышено количество символов
        displayTextField.font = UIFont.systemFont(ofSize: fontSize)
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
        
        if let currentText = displayTextField.text, currentText.count < 15 { // Проверяем количество символов
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
        let buttonTitles = [
            ["C", "0", ".", "="],
            ["1", "2", "3", "+"],
            ["4", "5", "6", "-"],
            ["7", "8", "9", "×"]
        ]
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let margin: CGFloat = 0
        let spacing: CGFloat = 1
        let buttonWidth = (screenWidth - 2 * margin - 3 * spacing) / 4
        let buttonHeight: CGFloat = (screenHeight - 2 * margin - 5 * spacing - 300) / 5
        let bottomMargin: CGFloat = 20 // Устанавливаем желаемый отступ от нижнего края
        
        var xPosition = margin
        var yPosition = screenHeight - margin - buttonHeight - view.safeAreaInsets.bottom - bottomMargin // Вычитаем отступ снизу
        
        for row in buttonTitles {
            for title in row {
                let button = UIButton(type: .system)
                button.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
                button.backgroundColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00)
                button.setTitleColor(UIColor.white, for: .normal)
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                view.addSubview(button)
                
                // Устанавливаем цвет фона и текста для каждой кнопки с помощью switch
                            switch title {
                            case "C":
                                button.backgroundColor = UIColor.systemOrange
                                button.setTitleColor(UIColor.white, for: .normal)
                            case "=", "+", "-", "×":
                                button.backgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.00)
                                button.setTitleColor(UIColor.white, for: .normal)
                            default:
                                button.backgroundColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.00)
                                button.setTitleColor(UIColor.white, for: .normal)
                            }
                
                xPosition += buttonWidth + spacing
            }
            xPosition = margin
            yPosition -= buttonHeight + spacing
        }
    }
    
}
