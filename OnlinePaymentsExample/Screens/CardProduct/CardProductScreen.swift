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

import SwiftUI
import OnlinePaymentsKit

struct CardProductScreen: View {

    private enum Constants {
        static let borderColor = Color(UIColor.gray)
        static let accentColor = Color(UIColor.darkGray)
        static let inactiveColor = Color(white: 0.8, opacity: 1.0)
    }

    // MARK: - State
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ViewModel

    @State private var showBottomSheet: Bool = false

    // MARK: - Body
    var body: some View {
        LoadingView(isShowing: $viewModel.isLoading) {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
                HeaderView()
                    .padding(.bottom, 30)

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.hasCardField {
                            ProductTextFieldView(leadingImage: Image(systemName: "creditcard"),
                                                 trailingImage:
                                    .image(
                                        Image(
                                            uiImage: viewModel.paymentProduct?.getLogoImage() ?? UIImage(),
                                        )
                                    ),
                                                 placeholder:
                                                    viewModel.placeholder(forField: viewModel.cardField),
                                                 text: viewModel.cardFieldEnabled ?
                                                 Binding<String>(
                                                    get: { viewModel.getCreditCardValue() },
                                                    set: { viewModel.onCreditCardFieldChanged(newValue: $0) }
                                                 ) :
                                    .constant(viewModel.accountOnFile?.label ?? ""),
                                                 accentColor:
                                                    viewModel.cardFieldEnabled ?
                                                 Constants.accentColor :
                                                    Constants.inactiveColor,
                                                 borderColor:
                                                    viewModel.cardFieldEnabled ?
                                                 Constants.borderColor :
                                                    Constants.inactiveColor,
                                                 errorText: viewModel.cardError,
                                                 onEditingChanged: { _ in },
                                                 onCommit: { }
                            )
                            .disabled(!viewModel.cardFieldEnabled)
                        }

                        HStack(alignment: .top) {
                            if viewModel.hasExpiryDateField {
                                ProductTextFieldView(leadingImage: Image(systemName: "calendar"),
                                                     trailingImage: .none,
                                                     placeholder:
                                                        viewModel.placeholder(forField: viewModel.expiryDateField),
                                                     text: viewModel.expiryDateFieldEnabled ?
                                                     Binding<String>(
                                                        get: {
                                                            viewModel.maskedValue(forField: viewModel.expiryDateField)
                                                        },
                                                        set: { viewModel.onExpiryDateFieldChanged(newValue: $0) }
                                                     ) :
                                        .constant(
                                            viewModel.accountOnFile?.getValue(
                                                id: AppConstants.expiryDateField
                                            ) ?? ""
                                        ),
                                                     accentColor:
                                                        viewModel.expiryDateFieldEnabled ?
                                                     Constants.accentColor :
                                                        Constants.inactiveColor,
                                                     borderColor:
                                                        viewModel.expiryDateFieldEnabled ?
                                                     Constants.borderColor :
                                                        Constants.inactiveColor,
                                                     errorText: viewModel.expiryDateError,
                                                     onEditingChanged: { _ in },
                                                     onCommit: {}
                                )
                                .disabled(!viewModel.expiryDateFieldEnabled)
                            }

                            if viewModel.hasCvvField {
                                ProductTextFieldView(leadingImage: Image(systemName: "lock"),
                                                     placeholder: viewModel.placeholder(forField: viewModel.cvvField),
                                                     text: Binding<String>(
                                                        get: { viewModel.maskedValue(forField: viewModel.cvvField) },
                                                        set: { viewModel.onCVVFieldChanged(newValue: $0) }
                                                     ),
                                                     errorText: viewModel.cvvError,
                                                     onEditingChanged: { _ in },
                                                     onCommit: {},
                                                     buttonCallback: {
                                                        showBottomSheetWithCVVInstruction()
                                                    }
                                )
                            }

                            if viewModel.hasSecurityCodeField {
                                ProductTextFieldView(leadingImage: Image(systemName: "lock"),
                                                     trailingImage: .none,
                                                     placeholder:
                                                        viewModel.placeholder(forField: viewModel.securityCodeField),
                                                     text: Binding<String>(
                                                        get: {
                                                            viewModel.maskedValue(forField: viewModel.securityCodeField)
                                                        },
                                                        set: { viewModel.onSecurityCodeFieldChanged(newValue: $0) }
                                                     ),
                                                     errorText: viewModel.securityCodeError,
                                                     onEditingChanged: { _ in },
                                                     onCommit: {}
                                )
                            }
                        }

                        if viewModel.hasCardHolderField {
                            ProductTextFieldView(leadingImage: Image(systemName: "person.fill"),
                                                 trailingImage: .none,
                                                 placeholder:
                                                    viewModel.placeholder(forField: viewModel.cardHolderField),
                                                 text: viewModel.cardHolderFieldEnabled ?
                                                 Binding<String>(
                                                    get: { viewModel.maskedValue(forField: viewModel.cardHolderField) },
                                                    set: { viewModel.onCardHolderNameFieldChanged(newValue: $0) }
                                                 ) :
                                    .constant(
                                        viewModel.accountOnFile?.getValue(
                                            id: AppConstants.cardHolderField
                                        ) ?? ""
                                    ),
                                                 accentColor:
                                                    viewModel.cardHolderFieldEnabled ?
                                                 Constants.accentColor :
                                                    Constants.inactiveColor,
                                                 borderColor:
                                                    viewModel.cardHolderFieldEnabled ?
                                                 Constants.borderColor :
                                                    Constants.inactiveColor,
                                                 errorText: viewModel.cardHolderError,
                                                 onEditingChanged: { _ in },
                                                 onCommit: {}
                            )
                            .disabled(!self.viewModel.cardHolderFieldEnabled)
                        }

                        if viewModel.accountOnFile == nil {
                            Toggle(isOn: $viewModel.rememberPaymentDetails) {
                                Text("RememberMyDetails".localized)
                                    .font(.footnote)
                            }
                        }
                        payButton

                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)

                    Spacer()

                    NavigationLink("", isActive: $viewModel.showEndScreen) {
                        if let encryptedRequest = viewModel.encryptedRequest {
                            EndScreen(viewModel: EndScreen.ViewModel(encryptedRequest: encryptedRequest))
                        } else {
                            // This should not never happen since showEndScreen is only true
                            // when preparedPaymentRequest has value
                            VStack {
                                HeaderView()
                                Text("NavigateToEndScreenErrorMessage".localized)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .alert(
                isPresented: $viewModel.showAlert,
                content: Alert.defaultErrorAlert(errorMessage: viewModel.errorMessage)
            )
            .bottomSheet(isPresented: $showBottomSheet,
                         headerType: .handle,
                         height: UIScreen.main.bounds.size.height * 0.3,
                         content: {
                Text("CVVTooltip".localized)
                    .padding(.horizontal)
            })
        }
    }

    // MARK: - Views
    private var payButton: some View {
        Button(action: {
            viewModel.pay()
        }, label: {
            Text("Pay".localized)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(viewModel.payIsActive ? Color.green : Color(UIColor.lightGray))
                .cornerRadius(5)
        })
        .disabled(!viewModel.payIsActive)
    }

    // MARK: - Functions
    private func showBottomSheetWithCVVInstruction() {
        self.showBottomSheet = true
    }
}

// MARK: - Previews
#Preview {
    let sessionData = SessionData(
        clientSessionId: "clientSessionId",
        customerId: "customerId",
        clientApiUrl: "clientApiUrl",
        assetUrl: "assetURL",
    )
    
    let configuration = SdkConfiguration(appIdentifier: "appIdentifier")
    
    let sdk = try! OnlinePaymentsSdk(sessionData: sessionData, configuration: configuration)

    let amountOfMoney = AmountOfMoney(amount: 10, currencyCode: "EUR")
    let paymentContext = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: false, countryCode: "NL")

    let viewModel = CardProductScreen.ViewModel(
        sdk: sdk,
        paymentContext: paymentContext,
        paymentProduct: nil,
        accountOnFile: nil
    )
    
    CardProductScreen(viewModel: viewModel)
}
