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

export function parseMarkdown(content: string, slug: string): ParsedDoc {
    const { data, content: markdownContent } = matter(content);
    return {
        frontmatter: data as DocFrontmatter,
        content: markdownContent,
        slug
    };
}