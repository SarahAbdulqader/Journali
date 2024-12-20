import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    let animationDuration: Double = 2.0 // مدة العرض
    
    var body: some View {
        if isActive {
            // بعد انتهاء شاشة البداية يتم عرض الصفحة الرئيسية
            MainPage()
        } else {
            // شاشة البداية
            VStack {
                Spacer()
                
                // إضافة صورة الشعار
                Image("Book") // تأكد أن "Logo" هو الاسم الصحيح للصورة في Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) // تعديل الحجم حسب الحاجة
                
               
                
                // إضافة النص الرئيسي
                Text("Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // إضافة النص الفرعي
                Text("Your thoughts, your story")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .background(Color.black) // لون الخلفية أسود كما في الصورة
            .edgesIgnoringSafeArea(.all) // تغطية كامل الشاشة
            .onAppear {
                // بدء مؤقت لتبديل الشاشة بعد مدة معينة
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

