import Foundation

public enum AIPipeline {
    public static func heuristicTag(text: String) -> (tags: [String], status: AIStatus) {
        let tags = HeuristicTagger().tags(forText: text)
        return (tags, tags.isEmpty ? .none : .done)
    }
}
