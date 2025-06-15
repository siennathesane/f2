// screens/docs/documentationScreen.tsx
import React from 'react';
import { ScrollView, ActivityIndicator, View } from 'react-native';
import Markdown from 'react-native-markdown-display';
import { useDocs } from '@/contexts/docsContext';
import { useLocalSearchParams, router } from 'expo-router';
import {Button, ButtonText} from "@/components/ui/button";
import {Text} from "@/components/ui/text";

export default function DocumentationScreen() {
    const { slug } = useLocalSearchParams<{ slug: string }>();
    const { docs, loading, error } = useDocs();

    if (loading) {
        return (
            <View className="flex-1 bg-background-primary justify-center items-center">
                <ActivityIndicator size="large" color="var(--text-brand-primary)" />
                <Text className="text-text-secondary mt-4">Loading documentation...</Text>
            </View>
        );
    }

    if (error) {
        return (
            <View className="flex-1 bg-background-primary justify-center items-center p-4">
                <Text className="text-error-500 text-center mb-4">{error}</Text>
                <Button onPress={() => router.push('/docs')}>
                    <ButtonText>Back to Docs</ButtonText>
                </Button>
            </View>
        );
    }

    const docSlug = slug || 'home';
    const docData = docs[docSlug];

    if (!docData) {
        const availableDocs = Object.keys(docs).join(', ');
        return (
            <View className="flex-1 bg-background-primary justify-center items-center p-4">
                <Text className="text-text-primary text-xl mb-2">Document not found</Text>
                <Text className="text-text-tertiary mb-2">Could not find: {docSlug}</Text>
                <Text className="text-text-muted text-sm mb-4">Available: {availableDocs}</Text>
                <Button onPress={() => router.push('/docs')}>
                    <ButtonText>Back to Docs</ButtonText>
                </Button>
            </View>
        );
    }

    return (
        <ScrollView className="flex-1 bg-background-primary">
            <View className="p-4">
                {/* Category badge */}
                <View className="mb-4">
                    <View className="bg-brand-primary-muted px-3 py-1 rounded-full self-start">
                        <Text className="text-brand-primary text-sm font-medium">
                            {docData.category}
                        </Text>
                    </View>
                </View>

                <Markdown
                    style={{
                        body: {
                            color: 'var(--text-text-secondary)',
                            fontSize: 16,
                            lineHeight: 24
                        },
                        heading1: {
                            color: 'var(--text-text-primary)',
                            fontSize: 28,
                            fontWeight: 'bold',
                            marginBottom: 16,
                            marginTop: 24
                        },
                        heading2: {
                            color: 'var(--text-text-primary)',
                            fontSize: 24,
                            fontWeight: 'bold',
                            marginBottom: 12,
                            marginTop: 20
                        },
                        heading3: {
                            color: 'var(--text-text-primary)',
                            fontSize: 20,
                            fontWeight: 'bold',
                            marginBottom: 8,
                            marginTop: 16
                        },
                        paragraph: {
                            color: 'var(--text-text-secondary)',
                            lineHeight: 24,
                            marginBottom: 16
                        },
                        code_inline: {
                            backgroundColor: 'var(--bg-background-tertiary)',
                            color: 'var(--text-text-primary)',
                            padding: 4,
                            borderRadius: 4,
                            fontFamily: 'monospace'
                        },
                        code_block: {
                            backgroundColor: 'var(--bg-background-tertiary)',
                            padding: 16,
                            borderRadius: 8,
                            marginBottom: 16,
                            fontFamily: 'monospace'
                        },
                        fence: {
                            backgroundColor: 'var(--bg-background-tertiary)',
                            padding: 16,
                            borderRadius: 8,
                            marginBottom: 16,
                            fontFamily: 'monospace'
                        },
                        link: {
                            color: 'var(--text-brand-primary)'
                        },
                        list_item: {
                            color: 'var(--text-text-secondary)',
                            marginBottom: 8
                        },
                        bullet_list: {
                            marginBottom: 16
                        },
                        ordered_list: {
                            marginBottom: 16
                        },
                        blockquote: {
                            backgroundColor: 'var(--bg-background-secondary)',
                            borderLeftWidth: 4,
                            borderLeftColor: 'var(--border-brand-primary)',
                            paddingLeft: 16,
                            paddingVertical: 12,
                            marginBottom: 16,
                            fontStyle: 'italic'
                        },
                        hr: {
                            backgroundColor: 'var(--border-border-secondary)',
                            height: 1,
                            marginVertical: 24
                        },
                        table: {
                            borderWidth: 1,
                            borderColor: 'var(--border-border-primary)',
                            marginBottom: 16
                        },
                        thead: {
                            backgroundColor: 'var(--bg-background-secondary)'
                        },
                        th: {
                            color: 'var(--text-text-primary)',
                            fontWeight: 'bold',
                            padding: 12,
                            borderBottomWidth: 1,
                            borderBottomColor: 'var(--border-border-primary)'
                        },
                        td: {
                            color: 'var(--text-text-secondary)',
                            padding: 12,
                            borderBottomWidth: 1,
                            borderBottomColor: 'var(--border-border-muted)'
                        }
                    }}
                    onLinkPress={(url) => {
                        // Handle internal links between docs
                        if (url.startsWith('/docs/')) {
                            const targetSlug = url.replace('/docs/', '');
                            router.push(`/docs/${targetSlug}`);
                            return false;
                        }
                        return true;
                    }}
                >
                    {docData.content}
                </Markdown>
            </View>
        </ScrollView>
    );
}