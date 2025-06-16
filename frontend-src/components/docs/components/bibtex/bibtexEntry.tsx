import React from 'react';
import { Box } from '@/components/ui/box';
import { VStack } from '@/components/ui/vstack';
import { HStack } from '@/components/ui/hstack';
import { Text } from '@/components/ui/text';

interface BibtexProps {
    children: string;
    className?: string;
}

interface BibtexEntry {
    type: string;
    key: string;
    fields: Record<string, string>;
}

export function BibtexEntry({ children, className }: BibtexProps) {
    const parseBibtex = (bibtexString: string): BibtexEntry[] => {
        const entries: BibtexEntry[] = [];
        const entryRegex = /@(\w+)\s*\{\s*([^,]+),\s*([\s\S]*?)\n\s*\}/g;

        let match;
        while ((match = entryRegex.exec(bibtexString)) !== null) {
            const [, type, key, fieldsString] = match;
            const fields: Record<string, string> = {};

            // Parse fields - handle both quoted and braced values
            const fieldRegex = /(\w+)\s*=\s*(?:\{([^}]*)\}|"([^"]*)"|(\w+))/g;
            let fieldMatch;

            while ((fieldMatch = fieldRegex.exec(fieldsString)) !== null) {
                const [, fieldName, bracedValue, quotedValue, bareValue] = fieldMatch;
                fields[fieldName.toLowerCase()] = bracedValue || quotedValue || bareValue || '';
            }

            entries.push({ type: type.toLowerCase(), key: key.trim(), fields });
        }

        return entries;
    };

    const formatAuthor = (author: string): string => {
        if (!author) return '';

        // Handle multiple authors separated by 'and'
        const authors = author.split(' and ').map(a => a.trim());

        if (authors.length === 1) {
            return authors[0];
        } else if (authors.length === 2) {
            return `${authors[0]} and ${authors[1]}`;
        } else {
            return `${authors[0]} et al.`;
        }
    };

    const formatYear = (year: string): string => {
        return year ? ` (${year})` : '';
    };

    const renderEntry = (entry: BibtexEntry): JSX.Element => {
        const { type, key, fields } = entry;

        const title = fields.title || '';
        const author = formatAuthor(fields.author || '');
        const year = formatYear(fields.year || '');
        const journal = fields.journal || '';
        const booktitle = fields.booktitle || '';
        const publisher = fields.publisher || '';
        const pages = fields.pages || '';
        const volume = fields.volume || '';
        const number = fields.number || '';
        const doi = fields.doi || '';
        const url = fields.url || '';

        let citation = '';
        let typeLabel = '';

        switch (type) {
            case 'article':
                typeLabel = 'Journal Article';
                citation = `${author}${year}. "${title}"`;
                if (journal) citation += ` ${journal}`;
                if (volume) citation += `, vol. ${volume}`;
                if (number) citation += `, no. ${number}`;
                if (pages) citation += `, pp. ${pages}`;
                citation += '.';
                break;

            case 'book':
                typeLabel = 'Book';
                citation = `${author}${year}. ${title}`;
                if (publisher) citation += `. ${publisher}`;
                citation += '.';
                break;

            case 'inproceedings':
            case 'incollection':
                typeLabel = type === 'inproceedings' ? 'Conference Paper' : 'Book Chapter';
                citation = `${author}${year}. "${title}"`;
                if (booktitle) citation += ` In ${booktitle}`;
                if (pages) citation += `, pp. ${pages}`;
                if (publisher) citation += `. ${publisher}`;
                citation += '.';
                break;

            case 'techreport':
                typeLabel = 'Technical Report';
                citation = `${author}${year}. "${title}"`;
                if (fields.institution) citation += `. ${fields.institution}`;
                if (fields.number) citation += `, Tech. Rep. ${fields.number}`;
                citation += '.';
                break;

            case 'phdthesis':
            case 'mastersthesis':
                typeLabel = type === 'phdthesis' ? 'PhD Thesis' : "Master's Thesis";
                citation = `${author}${year}. "${title}"`;
                if (fields.school) citation += `. ${fields.school}`;
                citation += '.';
                break;

            default:
                typeLabel = type.charAt(0).toUpperCase() + type.slice(1);
                citation = `${author}${year}. "${title}"`;
                if (journal || booktitle) citation += ` ${journal || booktitle}`;
                citation += '.';
        }

        return (
            <VStack key={key} className="mb-6 p-4 bg-background-secondary rounded-lg border border-border-primary">
                <HStack className="justify-between items-start mb-2">
                    <Text className="text-xs font-medium text-text-tertiary uppercase tracking-wide">
                        {typeLabel}
                    </Text>
                    <Text className="text-xs font-mono text-text-tertiary bg-background-tertiary px-2 py-1 rounded">
                        {key}
                    </Text>
                </HStack>

                <Text className="text-sm text-text-primary leading-relaxed mb-3">
                    {citation}
                </Text>

                {(doi || url) && (
                    <VStack className="gap-1">
                        {doi && (
                            <HStack className="items-center">
                                <Text className="text-xs font-medium text-text-tertiary w-12">DOI:</Text>
                                <Text className="text-xs font-mono text-text-secondary">{doi}</Text>
                            </HStack>
                        )}
                        {url && (
                            <HStack className="items-center">
                                <Text className="text-xs font-medium text-text-tertiary w-12">URL:</Text>
                                <Text className="text-xs font-mono text-text-secondary break-all">{url}</Text>
                            </HStack>
                        )}
                    </VStack>
                )}
            </VStack>
        );
    };

    const entries = parseBibtex(children.trim());

    if (entries.length === 0) {
        return (
            <VStack className="my-4">
                <Box className="bg-background-tertiary border border-border-primary border-b-0 rounded-t-lg px-4 py-2">
                    <Text className="text-xs text-text-tertiary uppercase font-medium">
                        bibtex
                    </Text>
                </Box>
                <Box className="bg-background-tertiary border border-border-primary p-4 rounded-b-lg">
                    <Text className="font-mono text-sm text-text-primary">{children}</Text>
                </Box>
            </VStack>
        );
    }

    return (
        <VStack className="my-4">
            <Box className="bg-background-tertiary border border-border-primary border-b-0 rounded-t-lg px-4 py-2">
                <HStack className="justify-between items-center">
                    <Text className="text-xs text-text-tertiary uppercase font-medium">
                        bibtex references
                    </Text>
                    <Text className="text-xs text-text-tertiary">
                        {entries.length} {entries.length === 1 ? 'entry' : 'entries'}
                    </Text>
                </HStack>
            </Box>
            <Box className="bg-background-primary border border-border-primary border-t-0 rounded-b-lg p-4">
                <VStack className="gap-0">
                    {entries.map(renderEntry)}
                </VStack>
            </Box>
        </VStack>
    );
}