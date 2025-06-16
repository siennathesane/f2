// contexts/docsContext.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import { Platform } from 'react-native';
import { Asset } from 'expo-asset';
import * as FileSystem from 'expo-file-system';
import matter from 'gray-matter';
import {docsMetadata, docsModules} from "@/components/docs/constants/docRegistry.generated";

export interface DocFrontmatter {
    title: string;
    description?: string;
    order?: number;
    privacy?: 'public' | 'private' | 'internal';
    author?: string;
    draft?: boolean;
    [key: string]: any;
}

export interface ParsedDoc {
    frontmatter: DocFrontmatter;
    content: string;
    slug: string;
    category: string;
}

interface DocsContextType {
    docs: Record<string, ParsedDoc>;
    loading: boolean;
    error: string | null;
    categories: string[];
}

const DocsContext = createContext<DocsContextType>({
    docs: {},
    loading: true,
    error: null,
    categories: []
});

// Helper to parse markdown with frontmatter
function parseMarkdown(content: string, slug: string, category: string): ParsedDoc {
    try {
        const { data, content: markdownContent } = matter(content);
        return {
            frontmatter: (data || { title: slug }) as DocFrontmatter,
            content: markdownContent,
            slug,
            category
        };
    } catch (error) {
        console.error(`Error parsing markdown for ${slug}:`, error);
        return {
            frontmatter: { title: slug },
            content: `Failed to parse document: ${slug}\n\nError: ${error.message}`,
            slug,
            category
        };
    }
}

// Cross-platform asset content loader
async function loadAssetContent(moduleAsset: any, slug: string): Promise<string> {
    if (Platform.OS === 'web') {
        // Web: Use fetch approach
        try {
            // Convert module to Asset to get the URI
            const asset = Asset.fromModule(moduleAsset);

            // On web, the asset.uri should be an HTTP URL we can fetch
            console.log(`🌐 Web: Fetching ${slug} from URI:`, asset.uri);

            if (!asset.uri) {
                throw new Error(`No URI available for ${slug}`);
            }

            const response = await fetch(asset.uri);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const content = await response.text();
            console.log(`📖 Web: Loaded ${slug}, length: ${content.length}`);
            return content;
        } catch (error) {
            console.error(`❌ Web fetch failed for ${slug}:`, error);
            throw error;
        }
    } else {
        // Mobile: Use expo-file-system approach
        try {
            console.log(`📱 Mobile: Loading ${slug} with FileSystem`);

            const asset = Asset.fromModule(moduleAsset);
            await asset.downloadAsync();

            if (!asset.localUri) {
                throw new Error(`No local URI for ${slug}`);
            }

            const content = await FileSystem.readAsStringAsync(asset.localUri);
            console.log(`📖 Mobile: Loaded ${slug}, length: ${content.length}`);
            return content;
        } catch (error) {
            console.error(`❌ Mobile load failed for ${slug}:`, error);
            throw error;
        }
    }
}

export const DocsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [state, setState] = useState<DocsContextType>({
        docs: {},
        loading: true,
        error: null,
        categories: []
    });

    useEffect(() => {
        const loadDocs = async () => {
            try {
                console.log(`📚 Loading docs on ${Platform.OS}...`);
                console.log('📦 Available modules:', Object.keys(docsModules));

                const docsData: Record<string, ParsedDoc> = {};
                const categoriesSet = new Set<string>();

                // Load each document with platform-appropriate method
                for (const metadata of docsMetadata) {
                    try {
                        console.log(`📄 Processing: ${metadata.slug}`);

                        const moduleAsset = docsModules[metadata.slug];
                        const content = await loadAssetContent(moduleAsset, metadata.slug);

                        if (!content || content.length < 10) {
                            throw new Error(`Content too short: ${content.length} chars`);
                        }

                        // Parse with gray-matter for proper YAML frontmatter
                        const parsedDoc = parseMarkdown(content, metadata.slug, metadata.category);

                        // Log privacy level for debugging
                        console.log(`🔒 ${metadata.slug} privacy: ${parsedDoc.frontmatter.privacy || 'not set'}`);

                        docsData[metadata.slug] = parsedDoc;
                        categoriesSet.add(metadata.category);

                        console.log(`✅ Successfully processed ${metadata.slug}`);
                    } catch (e) {
                        console.error(`❌ Failed to load ${metadata.slug}:`, e);

                        // Add error doc with proper frontmatter
                        docsData[metadata.slug] = {
                            frontmatter: {
                                title: `Error: ${metadata.slug}`,
                                privacy: 'public',
                                draft: true
                            },
                            content: `# Error Loading Document

**Document:** ${metadata.slug}  
**Category:** ${metadata.category}  
**Platform:** ${Platform.OS}  
**Error:** ${e.message}

This document could not be loaded. Please check:
1. The file exists in \`assets/docs/${metadata.filePath}\`
2. The file is valid markdown with proper frontmatter
3. Metro bundler configuration includes .md files

**Technical Details:**
\`\`\`
${e.stack || 'No stack trace available'}
\`\`\``,
                            slug: metadata.slug,
                            category: metadata.category
                        };
                        categoriesSet.add(metadata.category);
                    }
                }
                setState({
                    docs: docsData,
                    loading: false,
                    error: null,
                    categories: Array.from(categoriesSet).sort()
                });

            } catch (error) {
                console.error('💥 Critical error loading docs:', error);

                setState({
                    docs: {
                        'error': {
                            frontmatter: {
                                title: 'Critical Documentation Error',
                                privacy: 'public'
                            },
                            content: `# Documentation System Error

**Platform:** ${Platform.OS}  
**Error:** ${error.message}

The documentation system failed to initialize. Common causes:

### For Web:
- Asset URIs not accessible via fetch
- CORS issues with local assets
- Buffer polyfill not properly configured

### For Mobile:
- expo-file-system not available
- Asset download failed
- File permissions issue

### For Both:
- Registry not generated properly
- Markdown files missing from assets
- Metro bundler configuration issue

**Error Details:**
\`\`\`
${error.stack || 'No stack trace available'}
\`\`\`

**Debugging Steps:**
1. Check console for detailed error logs
2. Verify \`src/docs-registry.generated.ts\` exists
3. Confirm markdown files are in \`assets/docs/\`
4. Test asset loading manually`,
                            slug: 'error',
                            category: 'system'
                        }
                    },
                    loading: false,
                    error: error.message,
                    categories: ['system']
                });
            }
        };

        loadDocs();
    }, []);

    return (
        <DocsContext.Provider value={state}>
            {children}
        </DocsContext.Provider>
    );
};

export const useDocs = () => useContext(DocsContext);