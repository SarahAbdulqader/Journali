//
//  Untitled.swift
//  Journali
//
//  Created by SRO on 26/04/1446 AH.
//
import SwiftUI

struct JournalEntry: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let description: String
    var isBookmarked: Bool
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image("Book") // تأكد من وجود الصورة
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Begin Your Journal")
                .fontWeight(.bold)
                .foregroundColor(Color.pur) // تأكد من تعريف هذا اللون
                .font(.system(size: 24))

            Text("Craft your personal diary, tap the plus icon to begin")
                .multilineTextAlignment(.center)
                .controlSize(.mini)
                .padding(.top, 10)
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
    }
}

// الصفحة الرئيسية
struct MainPage: View {
    @State private var journalEntries = [JournalEntry]()
    @State private var filterByDate = false
    @State private var filterByBookmark = false
    @State private var showFilterOptions = false
    @State private var isSheetPresented = false
    @State private var selectedEntry: JournalEntry? // لإختيار المدخل عند التعديل
    @State private var isEditMode = false // تفعيل وضع التعديل
    @State private var searchText = "" // نص البحث

    var filteredEntries: [JournalEntry] {
        var entries = journalEntries
        if filterByBookmark {
            entries = entries.filter { $0.isBookmarked }
        }
        if filterByDate {
            entries.sort { $0.date < $1.date }
        }
        if !searchText.isEmpty {
            entries = entries.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return entries
    }

    var body: some View {
        NavigationView {
            VStack {
                if journalEntries.isEmpty {
                    EmptyStateView()
                } else {
                    ZStack {
                        TextField("Search by title", text: $searchText) // Updated placeholder
                            .padding(.leading, 10)
                            .frame(height: 40)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        
                        Button(action: {}) {
                            Image(systemName: "mic")
                                .foregroundColor(.gray)
                                .padding()
                        }
                        .padding(.leading, 299)
                    }
                    
                    List {
                        ForEach(filteredEntries.indices, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 220)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(filteredEntries[index].title)
                                            .font(.title)
                                            .bold()
                                            .foregroundColor(Color.pur)
                                        Spacer()
                                        Button(action: {
                                            journalEntries[index].isBookmarked.toggle()
                                        }) {
                                            Image(systemName: journalEntries[index].isBookmarked ? "bookmark.fill" : "bookmark")
                                                .foregroundColor(journalEntries[index].isBookmarked ? .pur : .gray)
                                        }
                                    }
                                    Text(filteredEntries[index].date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(filteredEntries[index].description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(26)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 5)
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    selectedEntry = journalEntries[index]
                                    isEditMode = true
                                    isSheetPresented = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.blue)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive, action: {
                                    journalEntries.remove(at: index)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Journal", displayMode: .automatic)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    showFilterOptions.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(Color.pur)
                            .frame(width: 30, height: 30)
                            .controlSize(.large)
                    }
                }
                .actionSheet(isPresented: $showFilterOptions) {
                    ActionSheet(
                        title: Text("Filter Options"),
                        buttons: [
                            .default(Text("All")) {
                                filterByDate = false
                                filterByBookmark = false
                            },
                            .default(Text("By Date")) {
                                filterByDate.toggle()
                            },
                            .default(Text("By Bookmark")) {
                                filterByBookmark.toggle()
                            },
                            .cancel()
                        ]
                    )
                }
                
                Button(action: {
                    selectedEntry = nil
                    isEditMode = false
                    isSheetPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        Image(systemName: "plus")
                            .foregroundColor(Color.pur)
                            .frame(width: 30, height: 30)
                            .controlSize(.large)
                    }
                }
                .sheet(isPresented: $isSheetPresented) {
                    NewJournalView(entry: selectedEntry) { newEntry in
                        if isEditMode, let selectedEntry = selectedEntry, let index = journalEntries.firstIndex(where: { $0.id == selectedEntry.id }) {
                            journalEntries[index] = newEntry
                        } else {
                            journalEntries.append(newEntry)
                        }
                    }
                }
            })
        }
    }
}

// صفحة إضافة المدخلات الجديدة
struct NewJournalView: View {
    @State private var title: String
    @State private var journalContent: String
    @State private var date: Date
    @Environment(\.presentationMode) var presentationMode
    var onSave: (JournalEntry) -> Void

    init(entry: JournalEntry?, onSave: @escaping (JournalEntry) -> Void) {
        self._title = State(initialValue: entry?.title ?? "")
        self._journalContent = State(initialValue: entry?.description ?? "")
        self._date = State(initialValue: entry?.date != nil ? Date() : Date()) // تأكد من أن التنسيق متناسق
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $title)
                    .foregroundColor(.pur)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 40)
                
                Text(dateFormatted(date: date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                TextEditor(text: $journalContent)
                
                Spacer()
            }
            .navigationBarTitle("New Journal", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.pur), trailing: Button("Save") {
                let newEntry = JournalEntry(
                    title: title,
                    date: dateFormatted(date: date),
                    description: journalContent,
                    isBookmarked: false
                )
                onSave(newEntry)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(title.isEmpty || journalContent.isEmpty))
        }
    }
    
    func dateFormatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MainPage()
}

