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

struct PaymentItemsOverviewScreen: View {

    // MARK: - State
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: ViewModel

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
                ScrollView {
                    if viewModel.hasAccountsOnFile && !viewModel.accountOnFileRows.isEmpty {
                        VStack(alignment: .leading) {
                            Text("PreviouslyUsedAccounts".localized)
                                .padding(.leading, 10)
                            accountsOnFileList
                            Text("OtherProducts".localized)
                                .padding(.leading, 10)
                            paymentItemsList
                        }
                    } else {
                        paymentItemsList
                    }
                }
                .padding(.top, 15)

                NavigationLink("", isActive: $viewModel.showCardProductScreen) {
                    CardProductScreen(
                        viewModel: .init(
                            sdk: viewModel.sdk,
                            paymentContext: viewModel.paymentContext,
                            paymentProduct: viewModel.selectedPaymentProduct,
                            accountOnFile: viewModel.selectedAccountOnFile
                        )
                    )
                }

                NavigationLink("", isActive: $viewModel.showSuccessScreen) {
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
            .alert(
                isPresented: $viewModel.showAlert,
                content: Alert.defaultErrorAlert(errorMessage: viewModel.errorMessage)
            )
            .bottomSheet(isPresented: $viewModel.showBottomSheet,
                         headerType: .handle,
                         height: UIScreen.main.bounds.size.height * 0.2,
                         content: {
                Text(viewModel.infoText)
                    .padding(.horizontal)
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Views
    private var accountsOnFileList: some View {
        ForEach(viewModel.accountOnFileRows, id: \.paymentProductIdentifier) { aof in
            PaymentItemListRowView(image: aof.logo, text: aof.name)
                .onTapGesture(perform: {
                    viewModel.didSelect(item: aof, isAccountOnFile: true)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
        }
    }

    private var paymentItemsList: some View {
        ForEach(viewModel.paymentProductRows, id: \.paymentProductIdentifier) { product in
            PaymentItemListRowView(image: product.logo, text: product.name)
                .onTapGesture(perform: {
                    viewModel.didSelect(item: product, isAccountOnFile: false)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
        }
    }
}
