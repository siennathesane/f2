import React, { useState } from 'react';
import { TouchableOpacity, Platform } from 'react-native';
import { Box } from '@/components/ui/box';
import { VStack } from '@/components/ui/vstack';
import { HStack } from '@/components/ui/hstack';
import { Text } from '@/components/ui/text';
import { MermaidRenderer } from '../mermaidRenderer';
import { useColorScheme } from '@/components/useColorScheme';

// For web - use the full react-syntax-highlighter
const WebSyntaxHighlighter = Platform.OS === 'web' ?
    require('react-syntax-highlighter').default : null;
const webStyles = Platform.OS === 'web' ?
    require('react-syntax-highlighter/dist/esm/styles/hljs') : null;

// For React Native - use the react-native wrapper with safe styles
const NativeSyntaxHighlighter = Platform.OS !== 'web' ?
    require('react-native-syntax-highlighter').default : null;
const nativeStyles = Platform.OS !== 'web' ?
    require('react-syntax-highlighter/dist/esm/styles/hljs') : null;

interface CodeBlockProps {
    children: string;
    className?: string;
}

export function CodeBlock({ children, className }: CodeBlockProps) {
    const [activeTab, setActiveTab] = useState('npm');
    const colorScheme = useColorScheme();

    // Extract language from className (e.g., "language-mermaid" -> "mermaid")
    const language = className?.replace('language-', '') || '';

    // Check if this is a Mermaid diagram
    if (language === 'mermaid') {
        return <MermaidRenderer chart={children.trim()} />;
    }

    // Check if this is a package manager command
    const isPackageManagerCode = children.includes('npm ') ||
        children.includes('yarn ') ||
        children.includes('pnpm ');

    if (isPackageManagerCode) {
        const tabs = [
            { id: 'npm', label: 'npm', prefix: 'npm' },
            { id: 'pnpm', label: 'pnpm', prefix: 'pnpm' },
            { id: 'yarn', label: 'Yarn', prefix: 'yarn' }
        ];

        const convertCommand = (command: string, targetManager: string) => {
            return command
                .replace(/npm install/g, targetManager === 'yarn' ? 'yarn add' : `${targetManager} install`)
                .replace(/npm run/g, targetManager === 'yarn' ? 'yarn' : `${targetManager} run`)
                .replace(/npm start/g, targetManager === 'yarn' ? 'yarn start' : `${targetManager} start`);
        };

        const HighlighterComponent = Platform.OS === 'web' ? WebSyntaxHighlighter : NativeSyntaxHighlighter;
        const styles = Platform.OS === 'web' ? webStyles : nativeStyles;
        const convertedCommand = convertCommand(children, activeTab);

        return (
            <VStack className="my-4">
                {/* Tabs */}
                <HStack className="bg-background-tertiary rounded-t-lg border border-border-primary border-b-0">
                    {tabs.map((tab) => (
                        <TouchableOpacity
                            key={tab.id}
                            onPress={() => setActiveTab(tab.id)}
                            className={`px-4 py-2 border-r border-border-primary last:border-r-0 ${
                                activeTab === tab.id
                                    ? 'bg-background-primary border-b border-background-primary'
                                    : 'hover:bg-background-secondary'
                            }`}
                        >
                            <Text
                                className={`text-sm font-medium ${
                                    activeTab === tab.id ? 'text-text-primary' : 'text-text-tertiary'
                                }`}
                            >
                                {tab.label}
                            </Text>
                        </TouchableOpacity>
                    ))}
                </HStack>

                {/* Code content with syntax highlighting */}
                <Box className="bg-background-tertiary border border-border-primary rounded-b-lg p-4">
                    {Platform.OS === 'web' && HighlighterComponent && styles ? (
                        <HighlighterComponent
                            language="bash"
                            style={colorScheme === 'dark' ? styles.atomOneDark : styles.atomOneLight}
                            customStyle={{
                                margin: 0,
                                padding: 0,
                                backgroundColor: 'transparent',
                                fontSize: 14,
                                lineHeight: 1.5,
                            }}
                            wrapLongLines={true}
                        >
                            {convertedCommand}
                        </HighlighterComponent>
                    ) : Platform.OS !== 'web' && HighlighterComponent && nativeStyles ? (
                        <HighlighterComponent
                            language="bash"
                            style={nativeStyles.docco} // Use safe native styles
                            fontSize={14}
                            highlighter="highlightjs"
                            fontFamily="monospace"
                        >
                            {convertedCommand}
                        </HighlighterComponent>
                    ) : (
                        <Text className="font-mono text-sm text-text-primary">
                            {convertedCommand}
                        </Text>
                    )}
                </Box>
            </VStack>
        );
    }

    // Regular code block with syntax highlighting
    const getSyntaxHighlighterLanguage = (lang: string): string => {
        const languageMap: Record<string, string> = {
            'js': 'javascript',
            'jsx': 'javascript',
            'ts': 'typescript',
            'tsx': 'typescript',
            'py': 'python',
            'rb': 'ruby',
            'sh': 'bash',
            'shell': 'bash',
            'yml': 'yaml',
        };

        return languageMap[lang.toLowerCase()] || lang.toLowerCase();
    };

    const highlighterLanguage = getSyntaxHighlighterLanguage(language);
    const HighlighterComponent = Platform.OS === 'web' ? WebSyntaxHighlighter : NativeSyntaxHighlighter;
    const styles = Platform.OS === 'web' ? webStyles : nativeStyles;

    return (
        <VStack className="my-4">
            {language && (
                <Box className="bg-background-tertiary border border-border-primary border-b-0 rounded-t-lg px-4 py-2">
                    <Text className="text-xs text-text-tertiary uppercase font-medium">
                        {language}
                    </Text>
                </Box>
            )}
            <Box className={`bg-background-tertiary border border-border-primary p-4 ${
                language ? 'rounded-b-lg' : 'rounded-lg'
            }`}>
                {Platform.OS === 'web' && HighlighterComponent && styles ? (
                    <HighlighterComponent
                        language={highlighterLanguage}
                        style={colorScheme === 'dark' ? styles.atomOneDark : styles.atomOneLight}
                        customStyle={{
                            margin: 0,
                            padding: 0,
                            backgroundColor: 'transparent',
                            fontSize: 14,
                            lineHeight: 1.5,
                            fontFamily: 'ui-monospace, SFMono-Regular, "SF Mono", Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
                        }}
                        wrapLongLines={true}
                        showLineNumbers={children.split('\n').length > 10}
                        lineNumberStyle={{
                            color: 'var(--text-text-tertiary)',
                            paddingRight: '16px',
                            fontSize: '12px',
                        }}
                    >
                        {children}
                    </HighlighterComponent>
                ) : Platform.OS !== 'web' && HighlighterComponent && nativeStyles ? (
                    <HighlighterComponent
                        language={highlighterLanguage}
                        style={nativeStyles.docco} // Use safe style for React Native
                        fontSize={14}
                        highlighter="highlightjs"
                        fontFamily="monospace"
                    >
                        {children}
                    </HighlighterComponent>
                ) : (
                    <Text className="font-mono text-sm text-text-primary">{children}</Text>
                )}
            </Box>
        </VStack>
    );
}