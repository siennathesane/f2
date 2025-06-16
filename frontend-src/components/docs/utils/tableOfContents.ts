import {TableOfContentsItem} from "@/components/docs/types";

export function extractTableOfContents(content: string): TableOfContentsItem[] {
    const headingRegex = /^(#{1,6})\s+(.+)$/gm;
    const toc: TableOfContentsItem[] = [];
    let match;

    while ((match = headingRegex.exec(content)) !== null) {
        const level = match[1].length;
        const title = match[2].trim();
        const id = title.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, '-');

        toc.push({
            id,
            title,
            level
        });
    }

    return toc;
}