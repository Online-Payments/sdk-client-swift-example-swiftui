/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import OnlinePaymentsKit
import SwiftUI

extension CardProductScreen {
    
    // swiftlint: disable type_body_length
    class ViewModel: ObservableObject {

        // MARK: - Properties
        private var creditCardFirstSixDigits: String = ""
        private var tokenize = false

        private var displayedValues = [String: String]()
        private var fieldValues = [String: String]()
        private var paymentRequest: PaymentRequest?
        private let cardFieldLimit: Int = 6

        var accountOnFile: AccountOnFile?
        var paymentProduct: PaymentProduct?
        var encryptedRequest: EncryptedRequest?

        // MARK: - State
        var hasCardField: Bool = false
        @Published var cardField: PaymentProductField?
        @Published var cardFieldEnabled: Bool = true
        @Published var cardError: String?

        var hasExpiryDateField: Bool = false
        @Published var expiryDateField: PaymentProductField?
        @Published var expiryDateFieldEnabled: Bool = true
        @Published var expiryDateError: String?

        var hasCvvField: Bool = false
        @Published var cvvField: PaymentProductField?
        @Published var cvvError: String?

        var hasSecurityCodeField: Bool = false
        @Published var securityCodeField: PaymentProductField?
        @Published var securityCodeError: String?

        var hasCardHolderField: Bool = false
        @Published var cardHolderField: PaymentProductField?
        @Published var cardHolderFieldEnabled: Bool = true
        @Published var cardHolderError: String?

        @Published var rememberPaymentDetails: Bool = false

        @Published var errorMessage: String?
        @Published var showAlert: Bool = false
        @Published var isLoading: Bool = false
        @Published var showEndScreen: Bool = false
        @Published var liveValidationEnabled: Bool = false
        @Published var payIsActive: Bool = false

        private let sdk: OnlinePaymentsSdk
        private let paymentContext: PaymentContext

        // MARK: - Init
        init(
            sdk: OnlinePaymentsSdk,
            paymentContext: PaymentContext,
            paymentProduct: PaymentProduct?,
            accountOnFile: AccountOnFile?
        ) {
            self.sdk = sdk
            self.paymentContext = paymentContext
            self.paymentProduct = paymentProduct
            self.accountOnFile = accountOnFile

            self.configurePaymentItemFields()
            self.configureAccountOnFileFields()
        }

        // MARK: - Fields callbacks
        func onCreditCardFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cardField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled || newValue.isEmpty == false {
                self.validateCard()
            }

            let inputData = self.unmaskedValue(forField: self.cardField)
            if inputData.count == self.cardFieldLimit &&
               self.creditCardFirstSixDigits != inputData &&
               hasCardHolderField {
                self.creditCardFirstSixDigits = inputData
                self.getIinDetails()
            }
        }

        func onExpiryDateFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.expiryDateField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled || newValue.isEmpty == false {
                self.validateExpiryDate()
            }
        }

        func onCVVFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cvvField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled || newValue.isEmpty == false {
                self.validateCVV()
            }
        }

        func onSecurityCodeFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.securityCodeField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled || newValue.isEmpty == false {
                self.validateSecurityCode()
            }
        }

        func onCardHolderNameFieldChanged(newValue: String) {
            self.setFieldValue(value: newValue, forField: self.cardHolderField, updatePaymentRequestFieldValues: true)

            evaluatePayButton()
            if self.liveValidationEnabled || newValue.isEmpty == false {
                self.validateCardHolderName()
            }
        }

        // MARK: - Fields helpers
        private func setFieldValue(
            value: String,
            forField paymentProductField: PaymentProductField?,
            updatePaymentRequestFieldValues: Bool
        ) {
            let fieldId = paymentProductField?.id ?? ""

            displayedValues[fieldId] = value
            if updatePaymentRequestFieldValues {
                fieldValues[fieldId] = value
            }
        }

        private func displayValue(forField paymentProductField: PaymentProductField?) -> String {
            let fieldId = paymentProductField?.id ?? ""

            guard let value = displayedValues[fieldId] else {
                return ""
            }

            return value
        }

        func maskedValue(forField paymentProductField: PaymentProductField?) -> String {
            let value = self.displayValue(forField: paymentProductField)
            guard let paymentProductField else {
                return value
            }

            return paymentProductField.applyMask(value: value) ?? value
        }

        private func unmaskedValue(forField paymentProductField: PaymentProductField?) -> String {
            let value = self.displayValue(forField: paymentProductField)
            guard let paymentProductField else {
                return value
            }

            return paymentProductField.removeMask(value: value) ?? value
        }

        func getCreditCardValue() -> String {
            // If accountOnFile cardNumber value equals current input,
            // then return the (unmasked) value, otherwise the masked value.
            // This is to ensure that the accountOnFile cardNumber is displayed correctly.
            if accountOnFile?.getValue(id: AppConstants.cardField) == displayValue(forField: cardField) {
                return displayValue(forField: cardField)
            } else {
                return maskedValue(forField: cardField)
            }
        }

        private func fieldIsPartOfAccountOnFile(paymentProductFieldId: String) -> Bool {
            return accountOnFile?.getValue(id: paymentProductFieldId) != nil
        }

        private func fieldIsReadOnly(paymentProductField: PaymentProductField?) -> Bool {
            let fieldId = paymentProductField?.id ?? ""
            guard !fieldId.isEmpty else {
                return false
            }
            
            if !fieldIsPartOfAccountOnFile(paymentProductFieldId: fieldId) {
                return false
            }
            
            return !(accountOnFile?.isWritable(id: fieldId) ?? true)
        }

        func placeholder(forField paymentProductField: PaymentProductField?) -> String {
            guard let paymentProductField else {
                return ""
            }

            let field = self.paymentProduct?.field(id: paymentProductField.id)

            return field?.displayHints.label ?? ""
        }

        // MARK: - Validators
        private func evaluatePayButton() {
            // Only validate if field is in product
            let validCardField =
                hasCardField ?
                    (!displayValue(forField: cardField).isEmpty && cardError == nil) :
                    true
            let validExpiryDateField =
                hasExpiryDateField ?
                    (!displayValue(forField: expiryDateField).isEmpty && expiryDateError == nil) :
                    true
            let validCvvField =
                hasCvvField ?
                    (!displayValue(forField: cvvField).isEmpty && cvvError == nil) :
                    true
            let validSecurityCodeField =
                hasSecurityCodeField ?
                    (!displayValue(forField: securityCodeField).isEmpty && securityCodeError == nil) :
                    true
            let validCardHolderField =
                hasCardHolderField ?
                    (!displayValue(forField: cardHolderField).isEmpty && cardHolderError == nil) :
                    true

            if validCardField &&
               validExpiryDateField &&
               validCvvField &&
               validSecurityCodeField &&
               validCardHolderField {
                payIsActive = true
            } else {
                payIsActive = false
            }
        }

        private func validateFields() {
            // Credit card number should not be validated when using an account on file,
            // since the value cannot be modified
            if accountOnFile == nil { validateCard()}
            if hasExpiryDateField { validateExpiryDate() }
            if hasCvvField { validateCVV() }
            if hasSecurityCodeField { validateSecurityCode() }
            if hasCardHolderField { validateCardHolderName() }
        }

        private func validateCard() {
            guard let cardField else {
                return
            }

            let errorMessageIds =
                cardField.validate(value: self.unmaskedValue(forField: self.cardField))

            cardError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateExpiryDate() {
            guard let expiryDateField,
                  !fieldIsReadOnly(paymentProductField: expiryDateField)
            else {
                return
            }

            let errorMessageIds =
                expiryDateField.validate(value: self.unmaskedValue(forField: self.expiryDateField))

            expiryDateError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateCVV() {
            guard let cvvField,
                  !fieldIsReadOnly(paymentProductField: cvvField) else {
                return
            }

            let errorMessageIds = cvvField.validate(value: self.unmaskedValue(forField: self.cvvField))

            cvvError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateSecurityCode() {
            guard let securityCodeField,
                  !fieldIsReadOnly(paymentProductField: securityCodeField) else {
                return
            }

            let errorMessageIds =
                securityCodeField.validate(
                    value: self.unmaskedValue(forField: self.securityCodeField)
                )

            securityCodeError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func validateCardHolderName() {
            guard let cardHolderField,
                  cardHolderField.dataRestrictions.isRequired,
                  !fieldIsReadOnly(paymentProductField: cardHolderField) else {
                return
            }

            let errorMessageIds =
                cardHolderField.validate(value: self.unmaskedValue(forField: self.cardHolderField))

            cardHolderError = getErrorMessage(validationErrors: errorMessageIds)
        }

        private func getErrorMessage(validationErrors: [ValidationErrorMessage]) -> String? {
            return !validationErrors.isEmpty ?
                ValidationErrorHandler.errorMessage(for: validationErrors[0], withCurrency: false) :
                nil
        }

        // MARK: - General Helpers
        private func createPaymentRequest() -> PaymentRequest {
            guard let paymentProduct else {
                fatalError("Invalid paymentItem")
            }

            let paymentRequest =
                PaymentRequest(
                    paymentProduct: paymentProduct,
                    accountOnFile: accountOnFile,
                    tokenize: self.tokenize
                )

            _ = Array(fieldValues.keys)

            do {
                for (key, value) in fieldValues {
                    try paymentRequest.field(id: key).setValue(value: value)
                }
                
                return paymentRequest
            } catch {
                showAlert(text: error.localizedDescription)
                
                fatalError("Failed to set payment request filed values: \(error)")
            }
        }

        private func configurePaymentItemFields() {
            guard let paymentProduct else {
                return
            }

            self.cardField = paymentProduct.field(id: AppConstants.cardField)
            if cardField != nil { self.hasCardField = true }

            self.expiryDateField = paymentProduct.field(id: AppConstants.expiryDateField)
            if expiryDateField != nil { self.hasExpiryDateField = true }

            self.cvvField = paymentProduct.field(id: AppConstants.cvvField)
            if cvvField != nil { self.hasCvvField = true }

            self.securityCodeField = paymentProduct.field(id: AppConstants.securityCodeField)
            if securityCodeField != nil { self.hasSecurityCodeField = true }

            self.cardHolderField = paymentProduct.field(id: AppConstants.cardHolderField)
            if cardHolderField != nil { self.hasCardHolderField = true }
        }

        private func configureAccountOnFileFields() {
            guard let accountOnFile else {
                return
            }

            setCreditCardFieldAccountOnFile(accountOnFile: accountOnFile)
            setExpiryDateFieldAccountOnFile(accountOnFile: accountOnFile)
            setCardHolderFieldAccountOnFile(accountOnFile: accountOnFile)
        }

        private func setCreditCardFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = cardField?.id ?? ""
            let value = accountOnFile.getValue(id: fieldId) ?? ""
            self.setFieldValue(value: value, forField: cardField, updatePaymentRequestFieldValues: false)
            // Always disable credit card field when using an account on file, the card number should never be modified
            cardFieldEnabled = false
        }

        private func setExpiryDateFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = expiryDateField?.id ?? ""
            let value = accountOnFile.getValue(id: fieldId) ?? ""
            self.setFieldValue(value: value, forField: expiryDateField, updatePaymentRequestFieldValues: false)
            expiryDateFieldEnabled = accountOnFile.isWritable(id: fieldId)
        }

        private func setCardHolderFieldAccountOnFile(accountOnFile: AccountOnFile) {
            let fieldId = cardHolderField?.id ?? ""
            let value = accountOnFile.getValue(id: fieldId) ?? ""
            self.setFieldValue(value: value, forField: cardHolderField, updatePaymentRequestFieldValues: false)
            cardHolderFieldEnabled = accountOnFile.isWritable(id: fieldId)
        }

        // MARK: - Actions
        func pay() {
            self.paymentRequest = self.createPaymentRequest()

            validateFields()

            guard cardError == nil &&
                    expiryDateError == nil &&
                    cvvError == nil &&
                    securityCodeError == nil &&
                    cardHolderError == nil
            else {
                liveValidationEnabled = true
                return
            }

            self.tokenize = rememberPaymentDetails

            guard let paymentRequest = self.paymentRequest else {
                return
            }

            self.isLoading = true

            sdk.encryptPaymentRequest(
                paymentRequest,
                success: { encryptedRequest in
                    self.isLoading = false

                    // ***************************************************************************
                    //
                    // The information contained in `preparedPaymentRequest.encryptedFields` should
                    // be provided via the S2S Create Payment API, using field `encryptedCustomerInput`.
                    //
                    // ***************************************************************************
                    self.encryptedRequest = encryptedRequest
                    self.showEndScreen = true
                },
                failure: { error in
                    self.isLoading = false
                    self.showAlert(text: error.localizedDescription)
                }
            )
        }

        private func getIinDetails() {
            sdk.iinDetails(
                forPartialCardNumber: self.unmaskedValue(forField: self.cardField),
                paymentContext: paymentContext,
                success: { iinDetailsResponse in
                    switch iinDetailsResponse.status {
                    case .supported:
                        self.switchToPaymentProduct(paymentProductId: iinDetailsResponse.paymentProductId)
                    case .existingButNotAllowed:
                        self.cardError = "ValidationErrors.allowedInContext".localized
                    default:
                        self.showAlert(text: "IINUnknown".localized)
                    }
                },
                failure: { error in
                    self.showAlert(text: error.localizedDescription)
                }
            )
        }

        private func switchToPaymentProduct(paymentProductId: Int?) {
            guard let paymentProductId else {
                return
            }
            
            if paymentProductId == self.paymentProduct?.id {
                return
            }
            
            sdk.paymentProduct(
                withId: paymentProductId,
                paymentContext: paymentContext,
                success: { paymentProduct in
                    self.paymentProduct = paymentProduct
                    self.cardError = nil
                    self.configurePaymentItemFields()
                }, failure: { error in
                    self.showAlert(text: error.localizedDescription)
                })
        }

        private func showAlert(text: String) {
            errorMessage = text
            showAlert = true
        }
    }
    // swiftlint: enable type_body_length
}
