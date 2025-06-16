// app/docs/_layout.tsx
import React from 'react';
import { Stack } from 'expo-router';
import { DocsProvider } from '@/contexts/docsContext';

export default function DocsLayout() {
    return (
        <DocsProvider>
            <Stack
                screenOptions={{
                    headerShown: false,
                }}
            >
                <Stack.Screen
                    name="[...slug]"
                    options={{ headerShown: false }}
                />
            </Stack>
        </DocsProvider>
    );
}