import React from 'react';
import { ScrollView, View, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { useDocs } from '@/contexts/docsContext';
import {Text} from "@/components/ui/text";

const categoryIcons: Record<string, string> = {
    'general': '📚',
    'workflows': '⚙️',
    'policies': '⚖️',
    'design': '🎨',
    'technical': '🔧',
    'api': '🔌'
};

const categoryNames: Record<string, string> = {
    'general': 'General',
    'workflows': 'Technical Workflows',
    'policies': 'Policies & Ethics',
    'design': 'Design System',
    'technical': 'Technical Docs',
    'api': 'API Reference'
};

export default function DocsIndex() {
    const router = useRouter();
    const { docs, categories, loading, error } = useDocs();

    if (loading) {
        return (
            <View className="flex-1 bg-background-primary justify-center items-center">
                <Text className="text-text-secondary">Loading documentation...</Text>
            </View>
        );
    }

    if (error) {
        return (
            <View className="flex-1 bg-background-primary justify-center items-center p-4">
                <Text className="text-error-500 text-center">{error}</Text>
            </View>
        );
    }

    // Group docs by category
    const groupedDocs = categories.reduce((acc, category) => {
        acc[category] = Object.values(docs).filter(doc => doc.category === category);
        return acc;
    }, {} as Record<string, typeof docs[string][]>);

    return (
        <ScrollView className="flex-1 bg-background-primary">
            <View className="p-4">
                <Text className="text-text-primary text-3xl font-bold mb-6">Documentation</Text>

                {categories.map(category => (
                    <View key={category} className="mb-8">
                        <View className="flex-row items-center mb-4">
                            <Text className="text-2xl mr-3">
                                {categoryIcons[category] || '📄'}
                            </Text>
                            <Text className="text-text-primary text-xl font-semibold">
                                {categoryNames[category] || category}
                            </Text>
                        </View>

                        <View className="space-y-3">
                            {groupedDocs[category]?.map(doc => (
                                <TouchableOpacity
                                    key={doc.slug}
                                    className="bg-background-secondary border border-border-primary rounded-lg p-4"
                                    onPress={() => router.push(`/docs/${doc.slug}`)}
                                >
                                    <Text className="text-text-primary text-lg font-medium mb-2">
                                        {doc.frontmatter.title}
                                    </Text>
                                    {doc.frontmatter.description && (
                                        <Text className="text-text-tertiary text-sm">
                                            {doc.frontmatter.description}
                                        </Text>
                                    )}
                                </TouchableOpacity>
                            ))}
                        </View>
                    </View>
                ))}
            </View>
        </ScrollView>
    );
}