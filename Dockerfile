# syntax=docker/dockerfile:1.7

FROM mikewhy/docker-iosevka-custom-build:v33.2.2@sha256:8d4cc2c29c4ce0ff72b184ae7fa4d4e1b573d49eef65774c224a6850e7dcdf8e as iosevka
RUN rm -rf /app
RUN apt-get update && apt-get install -y p7zip-full && rm -rf /var/lib/apt/lists/*
RUN npm install -g nushell
WORKDIR /build
RUN <<'EOF'
#!/usr/bin/env nu

http get 'https://github.com/be5invis/Iosevka/archive/v33.2.2.tar.gz' | tar xz --strip-components 1
npm i

ignore
EOF

FROM iosevka AS stage0
RUN <<'EOF'
#!/usr/bin/env nu

const name = 'Prestiga'
const version = '1.0.0'
const description = 'https://github.com/t5mat/prestiga'

let filter_weights = { select }
let filter_slopes = { select }
const export_glyph_names = true

const max_concurrent_jobs = null

let private_build_plans = do {
    let variants = {
        inherits: ss20
        design: {
            capital-b: more-asymmetric-interrupted-serifless
            capital-g: toothless-corner-serifless-hooked
            capital-j: serifed-both-sides
            capital-n: asymmetric-serifless
            capital-q: crossing
            capital-u: toothless-corner-serifless

            f: serifless-crossbar-at-x-height
            g: double-storey-open
            i: hooky
            j: flat-hook-serifed
            k: symmetric-connected-bottom-right-serifed
            l: hooky
            m: short-leg-serifless
            r: corner-hooked-serifless
            t: bent-hook-short-neck2
            u: toothless-corner-serifless

            one: base-flat-top-serif
            three: flat-top-serifless
            four: semi-open-non-crossing-serifless
            six: closed-contour
            seven: straight-serifed
            eight: two-circles
            nine: closed-contour

            diacritic-dot: square
            punctuation-dot: square
            asterisk: turn-hex-low
            brace: curly-flat-boundary
            number-sign: upright-open
            ampersand: upper-open
            at: fourfold
            dollar: interrupted
            question: corner
            cent: bar-interrupted
        }
        italic: {
            a: double-storey-tailed
            b: toothless-rounded-serifed
            d: tailed-serifed
            f: tailed-crossbar-at-x-height
            h: tailed-motion-serifed
            i: serifed-flat-tailed
            k: cursive-top-left-and-bottom-right-serifed
            l: serifed-flat-tailed
            m: short-leg-tailed-top-left-serifed
            n: tailed-motion-serifed
            p: eared-motion-serifed
            r: corner-hooked-top-serifed
            v: curly-motion-serifed
            y: curly-turn-serifless
        }
    }

    let weights = {
        Thin: {shape: 100 menu: 100 css: 100}
        ExtraLight: {shape: 200 menu: 200 css: 200}
        Light: {shape: 300 menu: 300 css: 300}
        Regular: {shape: 400 menu: 400 css: 400}
        Medium: {shape: 500 menu: 500 css: 500}
        SemiBold: {shape: 600 menu: 600 css: 600}
        Bold: {shape: 700 menu: 700 css: 700}
        ExtraBold: {shape: 800 menu: 800 css: 800}
        Heavy: {shape: 900 menu: 900 css: 900}
    } | do $filter_weights

    let slopes = {
        Upright: {angle: 0 shape: upright menu: upright css: normal}
        Oblique: {angle: 9.4 shape: oblique menu: oblique css: oblique}
        Italic: {angle: 9.4 shape: italic menu: italic css: italic}
    } | do $filter_slopes

    let widths = {
        Normal: {shape: 535 menu: 5 css: normal}
    }

    let metric_override = {
        leading: '1250'
        dotSize: 'default_dotSize * 0.96'
        periodSize: 'default_periodSize * 0.96'
        essRatio: 'default_essRatio * 0.8'
        sb: 'default_sb * 0.95'
        cap: '720'
        ascender: '720'
        xHeight: '720 * 0.75'
        symbolMid: '720 * 0.5'
        parenSize: '720 * 1.375'
        archDepth: 'default_archDepth * 0.9'
        smallArchDepth: 'default_smallArchDepth * 0.9'
    }

    let plan = {
        serifs: sans
        spacing: fixed
        noCvSs: true
        exportGlyphNames: $export_glyph_names
        weights: $weights
        slopes: $slopes
        widths: $widths
        variants: $variants
        metricOverride: $metric_override
        namingOverride: {version: $version description: $description}
    }

    {
        buildPlans: {$'($name)': {family: $'($name)' ...$plan}}
        collectPlans: {$'($name)': {release: true from: [$'($name)']}}
    }
}

$private_build_plans | to toml | save private-build-plans.toml
open build-plans.toml | update collectPlans { transpose k v | each {|r| {k: $r.k, v: ($r.v | reject release) } } | transpose -i -r -d } | save -f build-plans.toml
open package.json | update version $version | save -f package.json
(npm run build --
    ...(if ($max_concurrent_jobs | is-empty) {[]} else {[$'--jCmd=($max_concurrent_jobs)']})
    release:archives)

ignore
EOF

FROM scratch
COPY --from=stage0 /build/release-archives /
