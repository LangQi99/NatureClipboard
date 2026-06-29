import SwiftUI

struct SnippetsView: View {
    @EnvironmentObject var store: ClipboardStore
    @State private var showingNewSnippet = false
    @State private var editingSnippet: Snippet?
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss

    var filteredSnippets: [Snippet] {
        if searchText.isEmpty { return store.snippets }
        return store.snippets.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.keyword.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Snippets")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { showingNewSnippet = true }) {
                    Image(systemName: "plus")
                }
                Button("Done") { dismiss() }
            }
            .padding()

            TextField("Search snippets...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List {
                ForEach(filteredSnippets) { snippet in
                    SnippetRowView(snippet: snippet)
                        .contextMenu {
                            Button("Paste") { store.pasteSnippet(snippet) }
                            Button("Edit") { editingSnippet = snippet }
                            Button("Delete", role: .destructive) { store.deleteSnippet(snippet) }
                        }
                        .onTapGesture(count: 2) {
                            store.pasteSnippet(snippet)
                            dismiss()
                        }
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingNewSnippet) {
            SnippetEditorView(mode: .new)
                .environmentObject(store)
        }
        .sheet(item: $editingSnippet) { snippet in
            SnippetEditorView(mode: .edit(snippet))
                .environmentObject(store)
        }
    }
}

struct SnippetRowView: View {
    let snippet: Snippet

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(snippet.name)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text(snippet.keyword)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Text(snippet.content)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)
            HStack {
                Text(snippet.category)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary.opacity(0.7))
                Text("Used \(snippet.useCount)x")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}

enum SnippetEditorMode: Identifiable {
    case new
    case edit(Snippet)

    var id: String {
        switch self {
        case .new: return "new"
        case .edit(let s): return s.id.uuidString
        }
    }
}

struct SnippetEditorView: View {
    @EnvironmentObject var store: ClipboardStore
    @Environment(\.dismiss) var dismiss
    let mode: SnippetEditorMode
    @State private var name = ""
    @State private var content = ""
    @State private var keyword = ""
    @State private var category = "General"

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "Edit Snippet" : "New Snippet")
                .font(.headline)

            Form {
                TextField("Name", text: $name)
                TextField("Keyword (trigger)", text: $keyword)
                TextField("Category", text: $category)
                TextEditor(text: $content)
                    .frame(height: 120)
                    .font(.system(size: 12, design: .monospaced))
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button(isEditing ? "Save" : "Create") {
                    save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || content.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            if case .edit(let snippet) = mode {
                name = snippet.name
                content = snippet.content
                keyword = snippet.keyword
                category = snippet.category
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func save() {
        switch mode {
        case .new:
            let snippet = Snippet(name: name, content: content, keyword: keyword, category: category)
            store.addSnippet(snippet)
        case .edit(var snippet):
            snippet.name = name
            snippet.content = content
            snippet.keyword = keyword
            snippet.category = category
            store.updateSnippet(snippet)
        }
    }
}
