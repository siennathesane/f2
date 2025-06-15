import React from 'react';
import { DocsProvider } from '@/contexts/docsContext';
import DocumentationScreen from '@/screens/docs/documentationScreen';

export default function DocSlugScreen() {
    return (
        <DocsProvider>
            <DocumentationScreen />
        </DocsProvider>
    );
}