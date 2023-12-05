//
//  PlayerListenerList.swift
//  Cards
//
//  Created by Daniel Wells on 11/21/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class ListenerList {
    class Listener {
        var uid: String?
        var listenerObject: ListenerRegistration?
        var next: Listener?
        
        init(uid: String? = nil, listenerObject: ListenerRegistration? = nil, next: Listener? = nil) {
            self.uid = uid
            self.listenerObject = listenerObject
            self.next = next
        }
    }
    
    private var head: Listener?
    
    func addListener(uid: String, listenerObject: ListenerRegistration) {
        let node = Listener(uid: uid, listenerObject: listenerObject)
        
        if head == nil {
            head = node
        } else {
            node.next = head
            head = node
        }
    }
    
    func removeListener(uid: String) -> Bool {
        if head?.uid == uid {
            let temp = head?.next
            head = temp
            return true
        } else {
            var cur = head
            while cur?.next?.uid != uid {
                cur = cur?.next
            }
            
            if cur?.next?.uid != uid {
                Swift.print("uid isn't in list")
                return false
            } else {
                let temp = cur?.next?.next
                cur?.next = temp
                return true
            }
        }
    }
    
    func removeAllListeners() {
        var cur = head
        
        while cur != nil {
            _ = pop()
            cur = cur?.next
        }
    }
    
    func first() -> Listener? {
        return head
    }
    
    func pop() -> Listener {
        let temp = head
        head = head?.next
        return temp ?? Listener()
    }
    
    func contains(uid: String) -> Bool {
        var cur = head
        
        while cur != nil {
            if cur?.uid == uid {
                return true
            }
            cur = cur?.next
        }
        
        return false
    }
    
    func print() {
        var cur = head
        Swift.print("\n\nList of listeners:\n")
        while cur != nil {
            Swift.print(cur!.uid!)
            Swift.print(cur!.listenerObject!)
            cur = cur?.next
        }
    }
    
    func isEmpty() -> Bool {
        return head == nil
    }
}
