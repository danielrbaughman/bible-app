//
//  PassageView.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/17/25.
//

import SwiftUI

struct PassageView: View {
    var verseStart: Verse
    var verseEnd: Verse

    var body: some View {
        ScrollView {
            Text("""
                 Ut aute Lorem quis in dolore cillum proident. Lorem sit do incididunt tempor mollit. Tempor duis non labore cupidatat amet proident ut officia mollit eu veniam consectetur est Lorem ea. Nostrud laborum voluptate ea commodo commodo anim enim aliqua. Duis sit eiusmod mollit commodo ut.

                 Irure nostrud cupidatat est nostrud elit do minim ex qui consequat et laboris. Pariatur consectetur aute duis occaecat. Anim excepteur reprehenderit amet excepteur culpa aute tempor qui. Do ea sit ipsum ea. Consequat do in aliquip enim Lorem. Ipsum esse excepteur officia in deserunt cillum quis irure officia esse dolor magna anim aliqua aute. Aliqua veniam sit eiusmod veniam elit officia in duis.

                 Aute ut deserunt duis adipisicing aute mollit commodo veniam amet quis consequat do proident. Occaecat elit proident ad ipsum nostrud amet incididunt et commodo nulla occaecat in. Aliquip sit nisi laboris anim labore culpa culpa reprehenderit minim mollit pariatur sunt fugiat sint incididunt. Et nisi eiusmod deserunt eiusmod adipisicing incididunt consectetur. Eiusmod dolore sit fugiat nisi enim sint deserunt tempor Lorem eu. Cupidatat ullamco labore commodo eu esse ex consequat. Est officia aliquip enim consequat pariatur ut Lorem. Eu incididunt exercitation aliquip amet et.

                 Laboris pariatur enim Lorem. Aliquip magna tempor elit incididunt incididunt officia ipsum consectetur amet velit. Incididunt cillum non sit excepteur voluptate cillum. Sunt pariatur fugiat labore et adipisicing in non et dolor ut mollit id. Irure cupidatat ea consectetur dolore sit nulla Lorem officia irure sunt aliquip laboris dolor deserunt. Voluptate ad est nulla consectetur exercitation excepteur in ea elit amet mollit nostrud aute. Lorem aute adipisicing nulla excepteur non ullamco sint ut.

                 Qui aute duis culpa cillum ad mollit sit qui anim. Tempor sunt voluptate dolor enim est eiusmod aliquip velit. Tempor ipsum duis commodo ea reprehenderit. Laboris tempor esse magna magna dolore sint aliqua. Reprehenderit nulla sit adipisicing eu deserunt id aliqua officia ullamco enim dolore eu eu pariatur consequat. Voluptate eiusmod nisi incididunt do in in aliqua.
                """)
        }
    }
}

//#Preview {
//    let genesis = Book(id: "1", name: "Genesis")
//    PassageView(verseStart: Verse(book: genesis, chapter: 1, verse: 1), verseEnd: Verse(book: genesis, chapter: 1, verse: 1))
//}
