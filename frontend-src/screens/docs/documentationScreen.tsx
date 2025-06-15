// screens/docs/documentationScreen.tsx
import React from 'react';
import { ScrollView, StyleSheet, ActivityIndicator, View, Text } from 'react-native';
import Markdown from 'react-native-markdown-display';
import { useDocs } from '@/contexts/docsContext';
import { useLocalSearchParams, router } from 'expo-router';

export default function DocumentationScreen() {
    const { slug } = useLocalSearchParams<{ slug: string }>();
    const { docs, loading, error } = useDocs();

    if (loading) {
        return (
            <View style={styles.centered}>
                <ActivityIndicator size="large" />
            </View>
        );
    }

    if (error) {
        return (
            <View style={styles.centered}>
                <Text>Error: {error}</Text>
            </View>
        );
    }

    const docSlug = slug || 'index';
    const docData = docs[docSlug];

    if (!docData) {
        return (
            <View style={styles.centered}>
                <Text>Document not found: {docSlug}</Text>
            </View>
        );
    }

    return (
        <ScrollView style={styles.container}>
            <Text style={styles.title}>{docData.frontmatter.title}</Text>
            <Markdown
                style={markdownStyles}
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
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 16,
        backgroundColor: '#fff'
    },
    centered: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 16
    }
});

const markdownStyles = {
    body: { fontSize: 16, lineHeight: 24 },
    heading1: { fontSize: 24, marginTop: 16, marginBottom: 8 },
    heading2: { fontSize: 20, marginTop: 16, marginBottom: 8 },
    link: { color: '#0066cc' },
    paragraph: { marginBottom: 16 },
    list: { marginBottom: 16 },
    listItem: { marginBottom: 8 }
};