import Foundation

private struct PanguRegex {

    static private let CJK = "([\\p{InHiragana}\\p{InKatakana}\\p{InBopomofo}\\p{InCJKCompatibilityIdeographs}\\p{InCJKUnifiedIdeographs}])"
    static private func regex(with patten: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: patten, options: .caseInsensitive)
    }

    static let cjk_ans = regex(with: "\(CJK)([a-z0-9`~@\\$%\\^&\\*\\-_\\+=\\|\\\\/])")
    static let ans_cjk = regex(with: "([a-z0-9`~!\\$%\\^&\\*\\-_\\+=\\|\\\\;:,\\./\\?])\(CJK)")
    static let cjk_quote = regex(with: "([\"'])\(CJK)")
    static let quote_cjk = regex(with: "\(CJK)([\"'])")
    static let fix_quote = regex(with: "([\"'])(\\s*)(.+?)(\\s*)([\"'])")
    static let cjk_bracket_cjk = regex(with: "\(CJK)([\\({\\[]+(.*?)[\\)}\\]]+)\(CJK)")
    static let cjk_bracket = regex(with: "\(CJK)([\\(\\){}\\[\\]<>])")
    static let bracket_cjk = regex(with: "\(CJK)([\\(\\){}\\[\\]<>])")
    static let fix_bracket = regex(with: "([(\\({\\[)]+)(\\s*)(.+?)(\\s*)([\\)}\\]]+)")
    static let cjk_hash = regex(with: "\(CJK)(#(\\S+))")
    static let hash_cjk = regex(with: "((\\S+)#)\(CJK)")
}


public extension String {

    /// text with paranoid text spacing
    public var spaced: String {

        func passRule(_ rule: (NSRegularExpression, String), on string: String) -> String {
            return rule.0.stringByReplacingMatches(
                in: string, options:[],
                range: NSMakeRange(0, string.characters.count), withTemplate: rule.1)
        }

        var result = self
        result = passRule((PanguRegex.cjk_quote, "$1 $2"), on: result)
        result = passRule((PanguRegex.quote_cjk, "$1 $2"), on: result)
        result = passRule((PanguRegex.fix_quote, "$1$3$5"), on: result)

        let old = result
        result = passRule((PanguRegex.cjk_bracket_cjk, "$1 $2 $4"), on: result)

        if result == old {
            result = passRule((PanguRegex.cjk_bracket, "$1 $2"), on: result)
            result = passRule((PanguRegex.bracket_cjk, "$1 $2"), on: result)
        }

        result = passRule((PanguRegex.fix_bracket, "$1$3$5"), on: result)
        result = passRule((PanguRegex.cjk_hash, "$1 $2"), on: result)
        result = passRule((PanguRegex.hash_cjk, "$1 $3"), on: result)
        result = passRule((PanguRegex.cjk_ans, "$1 $2"), on: result)
        result = passRule((PanguRegex.ans_cjk, "$1 $2"), on: result)
        return result
    }

}

