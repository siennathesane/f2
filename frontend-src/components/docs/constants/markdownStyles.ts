export const markdownStyles = {
    body: {
        color: 'var(--text-text-secondary)',
        fontSize: 16,
        lineHeight: 26
    },
    heading1: {
        color: 'var(--text-text-primary)',
        fontSize: 32,
        fontWeight: '700',
        marginBottom: 20,
        marginTop: 32,
        lineHeight: 40
    },
    heading2: {
        color: 'var(--text-text-primary)',
        fontSize: 26,
        fontWeight: '600',
        marginBottom: 16,
        marginTop: 28,
        lineHeight: 34
    },
    heading3: {
        color: 'var(--text-text-primary)',
        fontSize: 22,
        fontWeight: '600',
        marginBottom: 12,
        marginTop: 24,
        lineHeight: 30
    },
    paragraph: {
        color: 'var(--text-text-secondary)',
        lineHeight: 26,
        marginBottom: 18
    },
    code_inline: {
        backgroundColor: 'var(--bg-background-tertiary)',
        color: 'var(--text-brand-primary)',
        padding: 6,
        borderRadius: 6,
        fontFamily: 'monospace',
        fontSize: 14
    },
    // Remove code_block and fence styles since we're handling them separately
    link: {
        color: 'var(--text-brand-primary)',
        textDecorationLine: 'underline'
    },
    list_item: {
        color: 'var(--text-text-secondary)',
        marginBottom: 8,
        lineHeight: 24
    },
    bullet_list: {
        marginBottom: 18,
        marginLeft: 16
    },
    ordered_list: {
        marginBottom: 18,
        marginLeft: 16
    },
    blockquote: {
        backgroundColor: 'var(--bg-brand-primary-muted)',
        borderLeftWidth: 4,
        borderLeftColor: 'var(--border-brand-primary)',
        paddingLeft: 20,
        paddingVertical: 16,
        marginBottom: 20,
        marginTop: 20,
        borderRadius: 6,
        fontStyle: 'italic'
    },
    hr: {
        backgroundColor: 'var(--border-border-secondary)',
        height: 1,
        marginVertical: 32
    },
    table: {
        borderWidth: 1,
        borderColor: 'var(--border-border-primary)',
        marginBottom: 20,
        borderRadius: 8,
        overflow: 'hidden'
    },
    thead: {
        backgroundColor: 'var(--bg-background-secondary)'
    },
    th: {
        color: 'var(--text-text-primary)',
        fontWeight: '600',
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: 'var(--border-border-primary)',
        textAlign: 'left'
    },
    td: {
        color: 'var(--text-text-secondary)',
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: 'var(--border-border-muted)'
    }
} as const;