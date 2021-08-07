//
//  ContentView.swift
//  ToDoList
//
//  Created by g on 2021/8/6.
//

import SwiftUI

func initUserData() -> [SingleToDo] {
    var output: [SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoList") as? Data {
        let data = try! decoder.decode([SingleToDo].self, from: dataStored)
        for item in data {
            if !item.deleted {
                output.append(
                    SingleToDo(
                        title: item.title,
                        duedate: item.duedate,
                        isChecked: item.isChecked,
                        isFavorite: item.isFavorite,
                        deleted: item.deleted,
                        id: output.count))
            }
        }
    }
    return output
}

struct ContentView: View {
    @ObservedObject var UserData: ToDo = ToDo(data: initUserData())
    @State var showEditingPage: Bool = false
    @State var selection: [Int] = []
    @State var editingMode: Bool = false
    @State var showLikeOnly: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(self.UserData.ToDoList) { item in
                            if !item.deleted {
                                if !self.showLikeOnly || item.isFavorite {                                        
                                    SingleCardView(
                                        index: item.id,
                                        editingMode: self.$editingMode,
                                        selection: self.$selection
                                    )
                                    .environmentObject(self.UserData)
                                    .padding(.top)
                                    .padding(.horizontal)
                                    .animation(.spring())
                                    .transition(.slide)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("提醒事项")
                .navigationBarItems(
                    trailing:
                        HStack(spacing: 20) {
                            if self.editingMode{
                                if !self.selection.isEmpty {
                                    deleteButton(selection: self.$selection)
                                        .environmentObject(self.UserData)
                                }
                            }
                            
                            editingButton(
                                editingMode: self.$editingMode,
                                selection: self.$selection
                            )
                            //                if !self.editingMode{
                            showLikeButton(showLikeOnly: self.$showLikeOnly)
                            //                }
                        }
                )
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        self.showEditingPage = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .foregroundColor(.blue)
                    }
                }
                .sheet(
                    isPresented: self.$showEditingPage,
                    content: {
                        EditingPage()
                            .environmentObject(self.UserData)
                    })
            }
        }
    }
}

struct editingButton: View {
    @Binding var editingMode: Bool
    @Binding var selection: [Int]
    
    var body: some View {
        Button(action: {
            self.editingMode.toggle()
            self.selection.removeAll()
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

struct deleteButton: View {
    
    @Binding var selection: [Int]
    @EnvironmentObject var UserData: ToDo
    
    var body: some View {
        Button(action: {
            for i in self.selection {
                self.UserData.delete(id: i)
            }
        }) {
            Image(systemName: "trash")
                .imageScale(.large)
        }
    }
}

struct showLikeButton:View {
    @Binding var showLikeOnly:Bool
    
    var body: some View {
        Button(action:{
            self.showLikeOnly.toggle()
        }){
            Image(systemName: self.showLikeOnly ? "star.fill" : "star")
                .imageScale(.large)
                .foregroundColor(.yellow)
        }
    }
}

struct SingleCardView: View {
    @EnvironmentObject var UserData: ToDo
    
    var index: Int
    
    @State var showEditingPage: Bool = false
    
    @Binding var editingMode: Bool
    @Binding var selection: [Int]
    var body: some View {
        HStack {
            Rectangle().frame(width: 6).foregroundColor(
                .blue)
            
            if self.editingMode {
                Button(action: {
                    self.UserData.delete(id: self.index)
                }) {
                    Image(systemName: "trash")
                        .imageScale(.large)
                        .padding(.leading)
                }
            }
            
            Button(
                action: {
                    if !self.editingMode {
                        self.showEditingPage = true
                    }
                }) {
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
            .sheet(
                isPresented: self.$showEditingPage,
                content: {
                    EditingPage(
                        title: self.UserData.ToDoList[self.index].title,
                        duedate: self.UserData.ToDoList[self.index].duedate,
                        isFavorite: self.UserData.ToDoList[self.index].isFavorite,
                        id: self.index
                    )
                    .environmentObject(self.UserData)
                })
            if self.UserData.ToDoList[index].isFavorite{
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            }
            
            
            if !self.editingMode {
                Image(
                    systemName: self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square"
                ).imageScale(.large).padding(.trailing)
                .onTapGesture {
                    self.UserData.check(id: self.index)
                }
            } else {
                Image(
                    systemName: self.selection.firstIndex(where: {
                        $0 == self.index
                    }) == nil ? "circle" : "checkmark.circle.fill"
                ).imageScale(.large).padding(.trailing)
                .onTapGesture {
                    if self.selection.firstIndex(where: {
                        $0 == self.index
                    }) == nil {
                        self.selection.append(self.index)
                    } else {
                        self.selection.remove(
                            at: self.selection.firstIndex(where: {
                                $0 == self.index
                            })!
                        )
                    }
                }
            }
        }.frame(height: 80)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            UserData: ToDo(data: [
                SingleToDo(title: "吃饭", duedate: Date(),isFavorite: true),
                SingleToDo(title: "写作业", duedate: Date(),isFavorite: false),
                SingleToDo(title: "看奥运直播", duedate: Date(),isFavorite: true),
                SingleToDo(title: "睡觉", duedate: Date(),isFavorite: false),
            ]))
    }
}
