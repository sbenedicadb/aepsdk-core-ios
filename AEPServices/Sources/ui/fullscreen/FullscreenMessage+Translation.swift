//
/*
 Copyright 2025 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
*/

#if os(iOS)
import Foundation
import Translation

@available(iOSApplicationExtension, unavailable)
extension FullscreenMessage {
    @available(iOS 18.0, *)
    func getTranslationConfiguration() async -> TranslationSession.Configuration? {
        let sourceLanguage = Locale(identifier: "en_US").language
                
        let preferredLanguage = Locale.Language(identifier: Locale.preferredLanguages.first ?? "en_US")
                
        let availability = LanguageAvailability()
                
        let status = await availability.status(from: sourceLanguage, to: preferredLanguage)
        
        guard status == .installed else {
            print("translation not available on-device: source or target language not downloaded (status: \(status))")
            return nil
        }
        
        return TranslationSession.Configuration(source: sourceLanguage, target: preferredLanguage)
    }
    
    /// Translates a batch of tokens using the provided configuration
    @available(iOS 18.0, *)
    func translateTokens(_ tokenMap: [String: String], configuration: TranslationSession.Configuration) async -> [String: String] {
        var translatedMap: [String: String] = [:]
        
        let english = Locale(identifier: "en_US").language
        
        if #available(iOS 26.0, *) {
            let session = TranslationSession(installedSource: configuration.source ?? english, target: configuration.target ?? english)
            
            // Translate each text in the token map
            for (token, originalText) in tokenMap {
                do {
                    let translationResponse = try await session.translate(originalText)
                    translatedMap[token] = translationResponse.targetText
                    print("Translated '\(originalText)' to '\(translationResponse.targetText)'")
                } catch {
                    print("Failed to translate text for token \(token): \(error)")
                    // Keep original text if translation fails
                    translatedMap[token] = originalText
                }
            }
                        
            return translatedMap
        } else {
            // Fallback on earlier versions
            return tokenMap
        }
    }
    
    // MARK: - HTML Processing
    
    /// Translates the HTML payload if translation is available
    @available(iOS 18.0, *)
    func translatePayloadIfNeeded() async {
        // Extract and tokenize visible text from HTML
        let (tokenizedHTML, tokenMap) = tokenizeHTMLText(payload)
        
        // Check if translation is available
        guard let config = await getTranslationConfiguration() else {
            print("Translation not available, using original payload")
            return
        }
        
        // Translate all tokens
        let translatedMap = await translateTokens(tokenMap, configuration: config)
        
        // Replace tokens with translated text
        let translatedPayload = replaceTokens(in: tokenizedHTML, with: translatedMap)
        
        // Update payload with translated content
        self.payload = translatedPayload
        print("Translated payload:")
        print(translatedPayload)
    }
    
    /// Extracts visible text from HTML, tokenizes it, and returns tokenized HTML with token map
    // swiftlint:disable function_body_length
    func tokenizeHTMLText(_ html: String) -> (tokenizedHTML: String, tokenMap: [String: String]) {
        var tokenizedHTML = html
        var tokenMap: [String: String] = [:]
        var tokenCounter = 1
        
        // Step 1: Extract and replace <style> and <script> blocks to prevent tokenizing code
        var preservedBlocks: [String: String] = [:]
        var blockCounter = 1
        
        // Remove <style> tags and their content
        if let styleRegex = try? NSRegularExpression(pattern: "<style[^>]*>.*?</style>", options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let nsString = tokenizedHTML as NSString
            let matches = styleRegex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let styleBlock = nsString.substring(with: match.range)
                let placeholder = "<!--PRESERVED_BLOCK_\(blockCounter)-->"
                preservedBlocks[placeholder] = styleBlock
                blockCounter += 1
                
                if let range = Range(match.range, in: tokenizedHTML) {
                    tokenizedHTML.replaceSubrange(range, with: placeholder)
                }
            }
        }
        
        // Remove <script> tags and their content
        if let scriptRegex = try? NSRegularExpression(pattern: "<script[^>]*>.*?</script>", options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let nsString = tokenizedHTML as NSString
            let matches = scriptRegex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let scriptBlock = nsString.substring(with: match.range)
                let placeholder = "<!--PRESERVED_BLOCK_\(blockCounter)-->"
                preservedBlocks[placeholder] = scriptBlock
                blockCounter += 1
                
                if let range = Range(match.range, in: tokenizedHTML) {
                    tokenizedHTML.replaceSubrange(range, with: placeholder)
                }
            }
        }
        
        // Regular expressions for extracting visible text
        // 1. Text between tags (excluding script, style, etc.)
        let textBetweenTagsPattern = ">([^<]+)<"
        // 2. alt attributes
        let altAttributePattern = "alt\\s*=\\s*[\"']([^\"']+)[\"']"
        // 3. title attributes
        let titleAttributePattern = "title\\s*=\\s*[\"']([^\"']+)[\"']"
        // 4. placeholder attributes
        let placeholderPattern = "placeholder\\s*=\\s*[\"']([^\"']+)[\"']"
                
        // Helper function to create token and update map
        func createToken(for text: String) -> String {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip empty strings or whitespace-only strings
            guard !trimmedText.isEmpty else { return text }
            
            let token = "$$T\(tokenCounter)$$"
            tokenMap[token] = trimmedText
            tokenCounter += 1
            return token
        }
        
        // Process text between tags
        if let regex = try? NSRegularExpression(pattern: textBetweenTagsPattern, options: []) {
            let nsString = tokenizedHTML as NSString
            let matches = regex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Process matches in reverse to maintain string indices
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let textRange = match.range(at: 1)
                    let text = nsString.substring(with: textRange)
                    
                    // Skip if it's just whitespace or newlines
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        continue
                    }
                    
                    let token = createToken(for: text)
                    if let range = Range(textRange, in: tokenizedHTML) {
                        tokenizedHTML.replaceSubrange(range, with: token)
                    }
                }
            }
        }
        
        // Process alt attributes
        if let regex = try? NSRegularExpression(pattern: altAttributePattern, options: [.caseInsensitive]) {
            let nsString = tokenizedHTML as NSString
            let matches = regex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let textRange = match.range(at: 1)
                    let text = nsString.substring(with: textRange)
                    let token = createToken(for: text)
                    if let range = Range(textRange, in: tokenizedHTML) {
                        tokenizedHTML.replaceSubrange(range, with: token)
                    }
                }
            }
        }
        
        // Process title attributes
        if let regex = try? NSRegularExpression(pattern: titleAttributePattern, options: [.caseInsensitive]) {
            let nsString = tokenizedHTML as NSString
            let matches = regex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let textRange = match.range(at: 1)
                    let text = nsString.substring(with: textRange)
                    let token = createToken(for: text)
                    if let range = Range(textRange, in: tokenizedHTML) {
                        tokenizedHTML.replaceSubrange(range, with: token)
                    }
                }
            }
        }
        
        // Process placeholder attributes
        if let regex = try? NSRegularExpression(pattern: placeholderPattern, options: [.caseInsensitive]) {
            let nsString = tokenizedHTML as NSString
            let matches = regex.matches(in: tokenizedHTML, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let textRange = match.range(at: 1)
                    let text = nsString.substring(with: textRange)
                    let token = createToken(for: text)
                    if let range = Range(textRange, in: tokenizedHTML) {
                        tokenizedHTML.replaceSubrange(range, with: token)
                    }
                }
            }
        }
        
        // Step 2: Restore preserved <style> and <script> blocks
        for (placeholder, originalBlock) in preservedBlocks {
            tokenizedHTML = tokenizedHTML.replacingOccurrences(of: placeholder, with: originalBlock)
        }
        
        return (tokenizedHTML, tokenMap)
    }
    // swiftlint:enable function_body_length
    
    /// Replaces tokens in HTML with their translated values
    func replaceTokens(in html: String, with translatedMap: [String: String]) -> String {
        var result = html
        for (token, translatedText) in translatedMap {
            result = result.replacingOccurrences(of: token, with: translatedText)
        }
        return result
    }
}
#endif
