// Types
export interface TableOfContentsItem {
    id: string;
    title: string;
    level: number;
}

export interface NavigationItem {
    title: string;
    slug?: string;
    category?: string;
    children?: NavigationItem[];
    isCategory?: boolean;
}

// Props interfaces for components
export interface NavigationSidebarProps {
    navigation: NavigationItem[];
    currentSlug: string | undefined;
    onNavigate: (slug: string) => void;
    isOpen: boolean;
    onClose: () => void;
}

export interface TableOfContentsSidebarProps {
    toc: TableOfContentsItem[];
    isOpen: boolean;
}

export interface CodeBlockProps {
    children: string;
    className?: string;
}

export interface MermaidRendererProps {
    chart: string;
    theme?: 'default' | 'dark' | 'forest' | 'neutral';
}
