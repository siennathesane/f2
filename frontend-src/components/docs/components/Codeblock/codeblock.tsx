import React, { useState } from 'react';
import { TouchableOpacity } from 'react-native';
import { Box } from '@/components/ui/box';
import { VStack } from '@/components/ui/vstack';
import { HStack } from '@/components/ui/hstack';
import { Text } from '@/components/ui/text';
import { MermaidRenderer } from '../mermaidRenderer';

interface CodeBlockProps {
    children: string;
    className?: string;
}

export function CodeBlock({ children, className }: CodeBlockProps) {
    const [activeTab, setActiveTab] = useState('npm');

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

                {/* Code content */}
                <Box className="bg-background-tertiary border border-border-primary rounded-b-lg p-4">
                    <Text className="font-mono text-sm text-text-primary">
                        {convertCommand(children, activeTab)}
                    </Text>
                </Box>
            </VStack>
        );
    }

    // Regular code block with syntax highlighting hint
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
                <Text className="font-mono text-sm text-text-primary">{children}</Text>
            </Box>
        </VStack>
    );
}