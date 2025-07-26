//
//  LandingPageView.swift
//  DailyReport
//
//  Created by Yonathan Hilkia on 21/07/25.
//

import SwiftUI
import FirebaseAuth

struct LandingPageView: View {
 
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView{
                ZStack{
                    Color("White")
                        .ignoresSafeArea()
                    
                    VStack {
                        ZStack {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    topLeading: 0,
                                    bottomLeading: 0,
                                    bottomTrailing: 140,
                                    topTrailing: 0
                                )
                            )
                            .fill(Color("Pink"))
                            .frame(width: geometry.size.width, height: 280)
                            .shadow(radius:4, x: 0, y: 4)
                            
                            VStack(alignment: .leading, spacing: 0){
                                Text("Welcome to FD \nReports")
                                    .font(.system(size: 48))
                                    .italic(true)
                                    .foregroundColor(Color("White"))
                                
                                Spacer().frame(height: 10)
                                Text("Log in with the account information given by FD staff")
                                    .font(.caption)
                                    .foregroundColor(Color("White"))
                            }.frame(width: geometry.size.width)
                        }
                        
                        Spacer().frame(height: 60)
                        VStack(spacing: 40) {
                            TextField("Email",text:$authManager.email)
                                .foregroundColor(.black)
                                .textFieldStyle(.plain)
                                .padding(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            SecureField("Password",text:$authManager.password)
                                .foregroundColor(.black)
                                .textFieldStyle(.plain)
                                .padding(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }.frame(width: 350)
                        Spacer().frame(height: 225)
                        VStack(spacing: 10) {
                            Button{
                                authManager.login()
                            }label: {
                                Text("Login")
                                    .font(.title2)
                                    .foregroundColor(Color("White"))
                                    .padding()
                                    .frame(width: 350, height: 50)
                            }.background(Color("Red"))
                            .cornerRadius(10)
                            
                        }
                        Spacer().frame(height: geometry.size.height * 0.08)

                    }
                } .frame(maxHeight: .infinity, alignment: .top)
            } .frame(minHeight: geometry.size.height)
        }
        .ignoresSafeArea()
    }
    
    }


#Preview {
    LandingPageView()
}
