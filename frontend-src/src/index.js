export default {
    async fetch(request, env, ctx) {
        // Let static assets pass through
        return new Response(null);
    }
}
