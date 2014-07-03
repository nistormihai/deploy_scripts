{
    "servers": {
        "nodejs": "$backend_url:$backend_port",
        "proxy": "$frontend_url",
        "livereload": 35729
    },
    "logging": {
        "nodejs": "appjs.log"
    },
    "paths": {
        "root": "$root/",
        "nodeModules": "<%= paths.root %>node_modules/",
        "scriptsRoot": "<%= paths.root %>gui-resources/",
        "scripts": "<%= paths.scriptsRoot %>scripts/js/",
        "themesRoot": "<%= paths.root %>gui-themes/",
        "themes": "<%= paths.themesRoot %>themes/",
        "build": "<%= paths.scripts %>build/",
        "logs": "<%= paths.root %>logs/",
        "test": "<%= paths.root %>test/",
        "docs": "<%= paths.root %>docs/",
        "docco": "<%= paths.docs %>docco/scripts",
        "doccoHusky": "<%= paths.docs %>docco-husky/scripts"
    },
    "liveblog": {
        "id": 1,
        "servers": {},
        "paths": {
            "scripts": "/content/lib/embed/scripts/js/",
            "css": "../../../content/lib/embed/",
            "themes": "../../themes/",
            "buildThemes": "./build/themes"
        },
        "render": "seo,embed",
        "theme": "zeit",
        "fallback": {
            "language": "de"
        },
        "hashmark": "#",
		"dev": true
    }
}
EOF
