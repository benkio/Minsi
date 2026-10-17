import { converter as tgMarkdownConverter } from 'tg-markdown-converter';

export function escapeMarkdown(markdown) {
    return function () {
        return tgMarkdownConverter(markdown);
    };
}
