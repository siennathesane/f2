import React from 'react';
import { View } from 'react-native';
import Markdown from 'react-native-markdown-display';
import { CodeBlock } from '../Codeblock/codeblock';

interface DocumentContentProps {
    content: string;
    markdownStyles: any;
    onLinkPress?: (url: string) => boolean;
}

interface ContentPart {
    type: 'markdown' | 'code';
    content: string;
    language?: string;
    key: string;
}

export function DocumentContent({ content, markdownStyles, onLinkPress }: DocumentContentProps) {

    const processContent = (): ContentPart[] => {
        const parts: ContentPart[] = [];

        // Regex to match fenced code blocks with optional language specifier
        const codeBlockRegex = /^```(\w+)?\s*\n([\s\S]*?)\n```$/gm;

        let lastIndex = 0;
        let match;

        // Reset regex lastIndex to ensure we start from the beginning
        codeBlockRegex.lastIndex = 0;

        while ((match = codeBlockRegex.exec(content)) !== null) {
            // Add markdown content before this code block
            if (match.index > lastIndex) {
                const markdownContent = content.slice(lastIndex, match.index).trim();
                if (markdownContent) {
                    parts.push({
                        type: 'markdown',
                        content: markdownContent,
                        key: `markdown-${lastIndex}-${match.index}`
                    });
                }
            }

            // Add the code block
            const language = match[1] || 'text';
            const codeContent = match[2];

            parts.push({
                type: 'code',
                content: codeContent,
                language: language,
                key: `code-${match.index}`
            });

            lastIndex = codeBlockRegex.lastIndex;
        }

        // Add any remaining markdown content after the last code block
        if (lastIndex < content.length) {
            const remainingContent = content.slice(lastIndex).trim();
            if (remainingContent) {
                parts.push({
                    type: 'markdown',
                    content: remainingContent,
                    key: `markdown-${lastIndex}-end`
                });
            }
        }

        // If no code blocks were found, treat the entire content as markdown
        if (parts.length === 0) {
            parts.push({
                type: 'markdown',
                content: content,
                key: 'markdown-full'
            });
        }

        return parts;
    };

    const contentParts = processContent();

    return (
        <View>
            {contentParts.map((part) => {
                if (part.type === 'code') {
                    return (
                        <CodeBlock
                            key={part.key}
                            className={`language-${part.language}`}
                        >
                            {part.content}
                        </CodeBlock>
                    );
                } else {
                    return (
                        <Markdown
                            key={part.key}
                            style={markdownStyles}
                            onLinkPress={onLinkPress}
                        >
                            {part.content}
                        </Markdown>
                    );
                }
            })}
        </View>
    );
}