//
//  ContentView.swift
//  ToDoList
//
//  Created by g on 2021/8/6.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var UserData: ToDo = ToDo(data: [
        SingleToDo(title: "吃饭", duedate: Date()),
        SingleToDo(title: "写作业", duedate: Date()),
        SingleToDo(title: "运动", duedate: Date()),
        SingleToDo(title: "睡觉", duedate: Date()),
    ])
    @State var showEditingPage: Bool = false
    
    
  var body: some View {
    ZStack{
        NavigationView{
            ScrollView(.vertical, showsIndicators: true) {
              VStack {
                ForEach(self.UserData.ToDoList) { item in
                  SingleCardView(index: item.id)
                    .environmentObject(self.UserData)
                    .padding()
                }
              }
            }
            .navigationBarTitle("提醒事项")
        }
        
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button(action:{
                    self.showEditingPage = true
                }){Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode:.fit)
                    .frame(width: 80)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)}
            }
            .sheet(isPresented: self.$showEditingPage, content: {
                EditingPage()
                    .environmentObject(self.UserData)
            })
        }
    }
  }
}

struct SingleCardView: View {
  @EnvironmentObject var UserData: ToDo
  var index: Int

  var body: some View {
    HStack {
      Rectangle().frame(width: 6).foregroundColor(
        .blue)

      VStack(
        alignment: .leading, spacing: 6.0,
        content: {
          Text(self.UserData.ToDoList[index].title).font(.headline).fontWeight(.heavy)
          Text(self.UserData.ToDoList[index].duedate.description).font(.subheadline)
            .foregroundColor(.gray)
        }
      ).padding(.leading)

      Spacer()

      Image(
        systemName: self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square"
      ).imageScale(.large).padding(.trailing)
        .onTapGesture {
          self.UserData.check(id: self.index)
        }
    }.frame(height: 80)
      .background(Color.white)
      .cornerRadius(10)
      .shadow(radius: 10, x: 0, y: 10)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
