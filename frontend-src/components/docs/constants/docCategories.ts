export const CATEGORY_ORDER = ['general', 'workflows', 'policies', 'design', 'technical', 'api'] as const;

export const CATEGORY_ICONS: Record<string, string> = {
    'general': '📚',
    'workflows': '⚙️',
    'policies': '⚖️',
    'design': '🎨',
    'technical': '🔧',
    'api': '🔌'
} as const;

export const CATEGORY_NAMES: Record<string, string> = {
    'general': 'General',
    'workflows': 'Technical Workflows',
    'policies': 'Policies & Ethics',
    'design': 'Design System',
    'technical': 'Technical Docs',
    'api': 'API Reference'
} as const;

export const PREFERRED_DEFAULT_DOCS = ['home', 'index', 'getting-started', 'ethics'] as const;