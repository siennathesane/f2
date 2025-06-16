import React from 'react';
import { View, Text } from 'react-native';
import {CodeBlock} from "@/components/docs/components/Codeblock/codeblock";

export function processMarkdownCodeBlocks(content: string): React.ReactElement[] {
    const parts = content.split(/(```[\s\S]*?```)/g);
    const elements: React.ReactElement[] = [];

    parts.forEach((part, index) => {
        if (part.startsWith('```') && part.endsWith('```')) {
            // This is a code block
            const lines = part.split('\n');
            const firstLine = lines[0].replace('```', '').trim();
            const language = firstLine || 'text';
            const code = lines.slice(1, -1).join('\n');

            elements.push(
                <CodeBlock
                    key={`code-${index}`}
                    className={`language-${language}`}
                >
                    {code}
                </CodeBlock>
            );
        } else if (part.trim()) {
            // This is regular markdown - we'll still use the markdown renderer for this part
            elements.push(
                <View key={`text-${index}`}>
                    <Text>{part}</Text>
                </View>
            );
        }
    });

    return elements;
}