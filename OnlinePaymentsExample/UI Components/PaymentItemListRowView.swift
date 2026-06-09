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

struct PaymentItemListRowView: View {
    // MARK: - Properties
    var image: UIImage?
    var text: String

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(12)
            HStack(spacing: 20) {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(text)
                Spacer()
            }
            .padding(.leading, 15)
            .padding(10)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Previews
#Preview {
    List {
        ForEach(0...5, id: \.self ) { index in
            PaymentItemListRowView(image: UIImage(), text: "Payment Item \(index)")
        }
    }
}
