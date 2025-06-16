// Navigation tree builder
import {NavigationItem} from "@/components/docs/types";
import {CATEGORY_ICONS, CATEGORY_NAMES, CATEGORY_ORDER} from "@/components/docs/constants/docCategories";

export function buildNavigationTree(docs: any, categories: string[]): NavigationItem[] {
    const sortedCategories = [...categories].sort((a, b) => {
        const aIndex = CATEGORY_ORDER.indexOf(a as any);
        const bIndex = CATEGORY_ORDER.indexOf(b as any);
        if (aIndex === -1 && bIndex === -1) return a.localeCompare(b);
        if (aIndex === -1) return 1;
        if (bIndex === -1) return -1;
        return aIndex - bIndex;
    });

    return sortedCategories.map(category => {
        const docsInCategory = Object.values(docs).filter((doc: any) => doc.category === category);
        const sortedDocs = docsInCategory.sort((a: any, b: any) => {
            const orderA = a.frontmatter.order || 999;
            const orderB = b.frontmatter.order || 999;
            if (orderA !== orderB) return orderA - orderB;
            return a.frontmatter.title.localeCompare(b.frontmatter.title);
        });

        return {
            title: `${CATEGORY_ICONS[category] || '📄'} ${CATEGORY_NAMES[category] || category}`,
            category,
            isCategory: true,
            children: sortedDocs.map((doc: any) => ({
                title: doc.frontmatter.title,
                slug: doc.slug,
                category: doc.category
            }))
        };
    });
}