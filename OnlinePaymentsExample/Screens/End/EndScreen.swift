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

struct EndScreen: View {

    // MARK: - State
    @ObservedObject var viewModel: ViewModel

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("SuccessLabel".localized)
                    .font(.largeTitle)
                Text("SuccessText".localized)
                    .font(.headline)
                Button(
                    viewModel.showEncryptedFields ?
                    "HideEncryptedDataResult".localized :
                    "ShowEncryptedDataResult".localized
                ) {
                    viewModel.showEncryptedFields.toggle()
                }

                if viewModel.showEncryptedFields {
                    VStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("EncryptedFieldsHeader".localized)
                                .bold()
                            Text(viewModel.encryptedRequest?.encryptedCustomerInput ?? "")
                        }
                        VStack(alignment: .leading) {
                            Text("EncryptedClientMetaInfoHeader".localized)
                                .bold()
                            Text(viewModel.encryptedRequest?.encodedClientMetaInfo ?? "")
                        }
                    }
                }

                Button(action: {
                    viewModel.copyToClipboard()
                }, label: {
                    Text("CopyEncryptedDataLabel".localized)
                        .foregroundColor(.green)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.green, lineWidth: 2)
                        )
                })

                Button(action: {
                    viewModel.returnToStart()
                }, label: {
                    Text("ReturnToStart".localized)
                        .foregroundColor(.red)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 2)
                        )
                })
            }
            .padding()
        }
    }
}

// MARK: - Previews
#Preview {
    EndScreen(viewModel: EndScreen.ViewModel(encryptedRequest: nil))
}
