//
//  UserData.swift
//  ToDoList
//
//  Created by g on 2021/8/6.
//

import Foundation

class ToDo: ObservableObject {
    @Published var ToDoList: [SingleToDo]
    var count = 0
    
    init(){
        self.ToDoList = []
    }
    init(data:[SingleToDo]){
        self.ToDoList = []
        for item in data {
            self.ToDoList.append(SingleToDo(title: item.title, duedate: item.duedate, id: self.count))
            count += 1
        }
    }
    func check(id: Int){
        self.ToDoList[id].isChecked.toggle()
    }
}

struct SingleToDo: Identifiable {
    var title:String = ""
    var duedate:Date = Date()
    var isChecked:Bool = false
    
    var id: Int = 0
}
