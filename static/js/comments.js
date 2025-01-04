(function() {
    // Configure script dynamically so the theme can be set based on user system preference
    const utterancesScript = document.createElement('script');
    utterancesScript.src = 'https://utteranc.es/client.js';
    utterancesScript.setAttribute('repo', 'parente/blog');
    utterancesScript.setAttribute('issue-term', "[${page['slug']}]");
    utterancesScript.setAttribute('crossorigin', 'anonymous');
    utterancesScript.setAttribute('async', '');
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        utterancesScript.setAttribute('theme', 'github-dark');
    } else {
        utterancesScript.setAttribute('theme', 'github-light');
    }
    // Insert the configured script into the DOM
    document.getElementById('userComments').appendChild(utterancesScript);

    // Listen for color scheme preference changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
        const theme = e.matches ? 'github-dark' : 'github-light';
        const iframe = document.querySelector('.utterances-frame');
        // Reload the iframe to change the theme to match. Utterances supports a 'set-theme' 
        // postMessage. However, tracking if the iframe has been added to the page by the initial
        // script in order to listen for whether the iframe has loaded lazily or not yet to decide
        // whether to postMessage or to update src involves more JS than I care to maintain for
        // this edge case. I accept the brief flicker of the iframe reloading.
        if(iframe) {
            const url = new URL(iframe.src);
            const searchParams = new URLSearchParams(url.search);
            searchParams.set('theme', theme);
            url.search = searchParams.toString();
            iframe.src = url.toString();
        }
    });
})();