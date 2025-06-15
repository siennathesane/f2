// app/docs/_layout.tsx
import React from 'react';
import { Stack } from 'expo-router';
import { DocsProvider } from '@/contexts/docsContext';

export default function DocsLayout() {
    return (
        <DocsProvider>
            <Stack
                screenOptions={{
                    headerStyle: { backgroundColor: 'var(--bg-background-primary)' },
                    headerTintColor: 'var(--text-text-primary)',
                    headerTitleStyle: { color: 'var(--text-text-primary)' }
                }}
            >
                <Stack.Screen
                    name="index"
                    options={{ title: 'Documentation' }}
                />
                <Stack.Screen
                    name="[slug]"
                    options={{ title: 'Document' }}
                />
            </Stack>
        </DocsProvider>
    );
}