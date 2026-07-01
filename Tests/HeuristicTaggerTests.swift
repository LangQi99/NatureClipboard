import Testing
@testable import ClipboardManagerKit

@Suite("HeuristicTagger") struct HeuristicTaggerTests {
    let tagger = HeuristicTagger()

    // MARK: - URL

    @Test func url_https_returnsUrlAndHost() {
        let tags = tagger.tags(forText: "https://github.com/openai/openai-python")
        #expect(tags.contains("url"))
        #expect(tags.contains("link"))
        #expect(tags.contains("github.com"))
    }

    @Test func url_http_returnsUrlTag() {
        #expect(tagger.tags(forText: "http://example.com/path").contains("url"))
    }

    @Test func nonUrl_plainWord_doesNotReturnUrl() {
        #expect(!tagger.tags(forText: "hello world").contains("url"))
    }

    // MARK: - Color

    @Test func hexColor_hash6_returnsHexAndColor() {
        let tags = tagger.tags(forText: "#4A7C4A")
        #expect(tags.contains("hex"))
        #expect(tags.contains("color"))
    }

    @Test func hexColor_hash3_returnsHex() {
        #expect(tagger.tags(forText: "#abc").contains("hex"))
    }

    @Test func rgbColor_returnsColor() {
        #expect(tagger.tags(forText: "rgb(255, 12, 0)").contains("color"))
    }

    @Test func hslColor_returnsColor() {
        #expect(tagger.tags(forText: "hsl(120, 50%, 40%)").contains("color"))
    }

    // MARK: - Email

    @Test func email_returnsEmailTag() {
        #expect(tagger.tags(forText: "foo@example.com").contains("email"))
    }

    // MARK: - Error / Stacktrace

    @Test func pythonTraceback_returnsErrorTag() {
        let stack = """
        Traceback (most recent call last):
          File "app.py", line 10, in <module>
        ValueError: bad value
        """
        let tags = tagger.tags(forText: stack)
        #expect(tags.contains("error"))
    }

    @Test func goPanic_returnsErrorTag() {
        #expect(tagger.tags(forText: "panic: runtime error: index out of range").contains("error"))
    }

    // MARK: - Code

    @Test func swiftCode_returnsCodeAndSwift() {
        let src = "func greet(name: String) -> String { return \"hi \\(name)\" }"
        let tags = tagger.tags(forText: src)
        #expect(tags.contains("code"))
        #expect(tags.contains("swift"))
    }

    @Test func pythonCode_returnsCodeAndPython() {
        let tags = tagger.tags(forText: "def add(x, y):\n    return x + y")
        #expect(tags.contains("code"))
        #expect(tags.contains("python"))
    }

    @Test func sqlCode_returnsSql() {
        let tags = tagger.tags(forText: "SELECT id, name FROM users WHERE age > 18")
        #expect(tags.contains("sql"))
        #expect(tags.contains("code"))
    }

    @Test func jsonCode_returnsJson() {
        #expect(tagger.tags(forText: "{\"key\": \"value\", \"n\": 1}").contains("json"))
    }

    @Test func htmlCode_returnsHtml() {
        #expect(tagger.tags(forText: "<div class=\"box\">hi</div>").contains("html"))
    }

    // MARK: - Long text

    @Test func longChineseText_returnsTextTag() {
        let text = String(repeating: "这是一段中文测试内容。", count: 20)
        #expect(tagger.tags(forText: text).contains("text"))
    }

    // MARK: - No overlap noise

    @Test func plainShortWord_returnsEmpty() {
        #expect(tagger.tags(forText: "hello").isEmpty)
    }
}
