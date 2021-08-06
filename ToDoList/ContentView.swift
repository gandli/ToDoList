//
//  ContentView.swift
//  ToDoList
//
//  Created by g on 2021/8/6.
//

import SwiftUI

func initUserData() -> [SingleToDo] {
    var output:[SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoList") as? Data  {
        let data = try! decoder.decode([SingleToDo].self, from: dataStored)
        for item in data {
            if !item.deleted {
                output.append(SingleToDo(title: item.title, duedate: item.duedate, isChecked: item.isChecked, deleted: item.deleted, id: output.count))
            }
        }
    }
    return output
}

struct ContentView: View {
    @ObservedObject var UserData: ToDo = ToDo(data:initUserData()
//                                                [SingleToDo(title: "吃饭", duedate: Date()),
//                                                 SingleToDo(title: "写作业", duedate: Date()),
//                                                 SingleToDo(title: "运动", duedate: Date()),
//                                                 SingleToDo(title: "睡觉", duedate: Date()),]
    )
    @State var showEditingPage: Bool = false
    
    
    var body: some View {
        ZStack{
            NavigationView{
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(self.UserData.ToDoList) { item in
                            if !item.deleted{
                                SingleCardView(index: item.id)
                                    .environmentObject(self.UserData)
                                    .padding(.top)
                                    .padding(.horizontal)
                            }
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
    
    @State var showEditingPage:Bool = false
    
    var body: some View {
        HStack {
            Rectangle().frame(width: 6).foregroundColor(
                .blue)
            
            Button(action:{
                self.UserData.delete(id: self.index)
            }){
                Image(systemName: "trash")
                    .imageScale(.large)
                    .padding(.leading)
            }
            
            Button(
                action:{
                    self.showEditingPage = true
                }){
                Group {
                    VStack(
                        alignment: .leading, spacing: 6.0,
                        content: {
                            Text(self.UserData.ToDoList[index].title).font(.headline).fontWeight(.heavy)
                                .foregroundColor(.black)
                            Text(self.UserData.ToDoList[index].duedate.description).font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    ).padding(.leading)
                    Spacer()
                }
            }
            .sheet(isPresented:self.$showEditingPage , content: {
                EditingPage(
                    title: self.UserData.ToDoList[self.index].title,
                    duedate: self.UserData.ToDoList[self.index].duedate,
                    id:self.index
                )
                .environmentObject(self.UserData)
            })
            
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
