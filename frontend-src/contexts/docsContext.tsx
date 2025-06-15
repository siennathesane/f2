// contexts/docsContext.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import * as FileSystem from 'expo-file-system';
import { Asset } from 'expo-asset';
import matter from 'gray-matter';

export interface DocFrontmatter {
    title: string;
    description?: string;
    order?: number;
    [key: string]: any;
}

export interface ParsedDoc {
    frontmatter: DocFrontmatter;
    content: string;
    slug: string;
}

interface DocsContextType {
    docs: Record<string, ParsedDoc>;
    loading: boolean;
    error: string | null;
}

const DocsContext = createContext<DocsContextType>({
    docs: {},
    loading: true,
    error: null
});

// Helper to parse markdown with frontmatter
function parseMarkdown(content: string, slug: string): ParsedDoc {
    try {
        const { data, content: markdownContent } = matter(content);
        return {
            frontmatter: (data || { title: slug }) as DocFrontmatter,
            content: markdownContent,
            slug
        };
    } catch (error) {
        console.error(`Error parsing markdown for ${slug}:`, error);
        return {
            frontmatter: { title: slug },
            content: `Failed to parse document: ${slug}`,
            slug
        };
    }
}

// This dynamically requires all MD files in the assets/docs directory
// Metro bundler will include all these files in the bundle
const getDocModules = () => {
    const context = require.context('../assets/docs', false, /\.md$/);
    const modules = {};
    context.keys().forEach(key => {
        // Convert './file.md' to 'file'
        const slug = key.replace(/^\.\//, '').replace(/\.md$/, '');
        modules[slug] = context(key);
    });
    return modules;
};

export const DocsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [state, setState] = useState<DocsContextType>({
        docs: {},
        loading: true,
        error: null
    });

    useEffect(() => {
        const loadDocs = async () => {
            try {
                const docsData = {};
                let docModules = {};

                try {
                    docModules = getDocModules();

                    // Process each module
                    const loadingPromises = Object.entries(docModules).map(
                        async ([slug, module]) => {
                            try {
                                const asset = Asset.fromModule(module);
                                await asset.downloadAsync();

                                if (asset.localUri) {
                                    const content = await FileSystem.readAsStringAsync(asset.localUri);
                                    docsData[slug] = parseMarkdown(content, slug);
                                }
                            } catch (e) {
                                console.warn(`Failed to load doc: ${slug}`, e);
                            }
                        }
                    );

                    await Promise.all(loadingPromises);

                } catch (error) {
                    console.warn("Could not load bundled docs, falling back to examples", error);
                    throw error;
                }

                // Check if we loaded any docs
                if (Object.keys(docsData).length > 0) {
                    setState({
                        docs: docsData,
                        loading: false,
                        error: null
                    });
                } else {
                    throw new Error("No documents could be loaded");
                }
            } catch (error) {
                console.error("Failed to load docs:", error);

                // Fallback to example docs
                const exampleDocs = {
                    'index': `---\ntitle: Documentation Home\n---\n# Welcome to the Documentation\n\nThis is the main documentation page.`,
                    'ethics': `---\ntitle: Ethics Guide\n---\n# Ethics Guide\n\nThis guide covers ethical considerations.`
                };

                const parsedDocs = Object.entries(exampleDocs).reduce((acc, [slug, content]) => {
                    return { ...acc, [slug]: parseMarkdown(content, slug) };
                }, {});

                setState({
                    docs: parsedDocs,
                    loading: false,
                    error: "Could not load documentation files. Showing examples."
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