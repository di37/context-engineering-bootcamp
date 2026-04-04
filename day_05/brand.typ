// ============================================================
// Isham Rashik — Brand Design System for Typst
// Engineering AI with Clarity
// ============================================================

// --- External Packages ---
// gentle-clues: Professional callout/admonition boxes
#import "@preview/gentle-clues:1.2.0": *

// fletcher and cetz are imported per-document when needed (see SKILL.md).
// They are NOT imported here because not every document needs diagrams,
// and importing them globally would slow compilation.

// --- Brand Colors ---
#let navy   = rgb("#0B1E3D")
#let blue   = rgb("#1A56DB")
#let teal   = rgb("#0891B2")
#let cyan   = rgb("#06B6D4")
#let mist   = rgb("#BAE6FD")
#let ice    = rgb("#F0F9FF")
#let white  = rgb("#FFFFFF")
#let gray   = rgb("#64748B")
#let light-gray = rgb("#E2E8F0")
#let amber  = rgb("#F59E0B")
#let green  = rgb("#10B981")

// --- Brand Identity ---
#let brand-name       = "Isham Rashik"
#let brand-title      = "AI Engineer"
#let brand-slogan     = "Engineering AI with Clarity"
#let brand-descriptor = "NLP • Computer Vision • Fine-Tuning • RAG • Agentic AI"
#let brand-github     = "github.com/di37"
#let brand-huggingface = "huggingface.co/disham993"
#let brand-linkedin   = "linkedin.com/in/isham-rashik-5a547711b"
#let brand-location   = "Dubai, UAE"

// --- Category Labels ---
#let categories = (
  "NLP", "COMPUTER VISION", "FROM SCRATCH", "FINE-TUNING",
  "RAG SYSTEMS", "AGENTIC AI", "MULTIMODAL", "EVALUATION",
)

// ============================================================
// CUSTOM FUNCTIONS
// ============================================================

// --- Category Badge ---
#let badge(label) = {
  box(
    fill: teal,
    radius: 12pt,
    inset: (x: 10pt, y: 4pt),
    text(font: "sans-serif", size: 8pt, weight: "bold", fill: white, upper(label))
  )
}

// ============================================================
// CALLOUT BOXES — powered by gentle-clues
// ============================================================
// The package provides these ready-to-use clue types:
//
//   #tip[...]         — Tips and best practices (green accent)
//   #info[...]        — Informational notes (blue accent)
//   #warning[...]     — Warnings and cautions (yellow accent)
//   #danger[...]      — Critical danger notices (red accent)
//   #error[...]       — Error messages (red accent)
//   #success[...]     — Success confirmations (green accent)
//   #example[...]     — Worked examples (purple accent)
//   #question[...]    — Questions to consider (cyan accent)
//   #memo[...]        — Notes to remember (blue-gray accent)
//   #abstract[...]    — Summaries/abstracts (teal accent)
//   #conclusion[...]  — Key conclusions (purple accent)
//   #task[...]        — Action items with counter (green accent)
//   #idea[...]        — Ideas and innovations (yellow accent)
//   #quotation[...]   — Block quotes (gray accent)
//   #goal[...]        — Objectives/goals (red accent)
//   #experiment[...]  — Experimental notes (orange accent)
//   #notify[...]      — Notifications (blue accent)
//   #code[...]        — Code-related notes (dark accent)
//
// All support optional title parameter: #tip(title: "Pro Tip")[...]
//
// Custom branded clue using the base function:
//   #clue(title: "Custom", accent-color: teal)[...]

// --- Key Insight Box (custom, brand-specific) ---
// For the most important takeaway in a section. Uses navy background
// with light text for maximum visual weight.
#let insight(body) = {
  block(
    width: 100%,
    breakable: false,
    inset: 14pt,
    fill: navy,
    radius: 4pt,
    text(fill: mist, size: 11pt, style: "italic", body)
  )
}

// --- Branded Code Block (uncaptioned) — colorful header + teal accent + cyan code ---
#let code-block(lang: "python", body) = {
  align(left,
    block(width: 100%, radius: 4pt, clip: true, stroke: 0.5pt + rgb("#1E3A5F"), {
      // Header bar with language badge
      block(width: 100%, fill: rgb("#0F2847"), inset: (x: 14pt, y: 6pt), {
        grid(columns: (auto, 1fr, auto),
          box(fill: teal, radius: 3pt, inset: (x: 8pt, y: 3pt),
            text(font: "monospace", size: 7pt, fill: white, weight: "bold", upper(lang))
          ),
          [],
          text(font: "monospace", size: 7pt, fill: gray)[·  ·  ·],
        )
      })
      // Code body with left accent
      block(width: 100%, fill: navy, inset: (left: 14pt, rest: 12pt), stroke: (left: 3pt + teal), {
        set align(left)
        set text(font: "monospace", size: 9pt)
        set par(leading: 0.65em)
        text(fill: cyan, body)
      })
    })
  )
}

// --- Captioned Code Block — colorful header + teal accent + caption at bottom ---
#let branded-code(body, lang: "python", caption: none) = {
  let code-content = block(width: 100%, radius: 4pt, clip: true, stroke: 0.5pt + rgb("#1E3A5F"), {
    // Header bar with language badge
    block(width: 100%, fill: rgb("#0F2847"), inset: (x: 14pt, y: 6pt), {
      grid(columns: (auto, 1fr, auto),
        box(fill: teal, radius: 3pt, inset: (x: 8pt, y: 3pt),
          text(font: "monospace", size: 7pt, fill: white, weight: "bold", upper(lang))
        ),
        [],
        text(font: "monospace", size: 7pt, fill: gray)[·  ·  ·],
      )
    })
    // Code body with left accent
    block(width: 100%, fill: navy, inset: (left: 14pt, rest: 12pt), stroke: (left: 3pt + teal), {
      set align(left)
      set text(font: "monospace", size: 9pt)
      set par(leading: 0.65em)
      text(fill: cyan, body)
    })
  })
  if caption != none {
    align(left, figure(kind: "code", supplement: [Code], code-content, caption: caption))
  } else { code-content }
}

// --- Metric Highlight ---
#let metric(label, value, delta: none) = {
  box(
    inset: (x: 12pt, y: 8pt),
    radius: 4pt,
    fill: ice,
    stroke: 1pt + light-gray,
    [
      #text(size: 8pt, fill: gray, upper(label)) \
      #text(size: 18pt, weight: "bold", fill: navy, value)
      #if delta != none {
        text(size: 10pt, fill: teal, [ #delta])
      }
    ]
  )
}

// --- Section Divider ---
#let divider() = {
  v(8pt)
  line(length: 100%, stroke: 1pt + light-gray)
  v(8pt)
}

// --- Brand Footer ---
#let brand-footer() = {
  divider()
  set text(size: 8pt, fill: gray)
  [
    _#brand-name --- #brand-title · #brand-slogan _ \
    _#brand-descriptor _ \
    _#brand-github · #brand-huggingface · #brand-location _
  ]
}

// --- LinkedIn CTA (end-of-document call to action) ---
// Always renders on its own dedicated last page.
#let brand-cta(qr-path: "linkedin-qr.png") = {
  pagebreak()
  v(1fr)
  block(width: 100%, breakable: false, {
    grid(
      columns: (1fr, auto),
      gutter: 20pt,
      {
        text(size: 18pt, weight: "bold", fill: navy)[Follow me for More AI Content]
        v(8pt)
        text(size: 11pt, fill: navy)[If you found these notes useful, connect with me on LinkedIn for more deep dives into Machine Learning, Artificial Intelligence, and Computer Vision.]
        v(12pt)
        link("https://linkedin.com/in/isham-rashik-5a547711b")[
          #text(size: 13pt, weight: "bold", fill: blue)[Isham Rashik on LinkedIn]
        ]
        v(4pt)
        text(size: 9pt, fill: gray)[Scan the QR code or click the link above]
      },
      image(qr-path, width: 100pt),
    )
  })
  v(1fr)
}

// --- Decision Framework ---
#let decision(..items) = {
  block(
    width: 100%,
    breakable: false,
    inset: 12pt,
    fill: ice,
    radius: 4pt,
    stroke: 1pt + light-gray,
    {
      for item in items.pos() {
        [#text(fill: teal, weight: "bold")[If #item.condition] → #text(fill: navy, weight: "bold")[#item.action] — #item.reason \ ]
      }
    }
  )
}

// --- Step List ---
#let steps(..items) = {
  for (i, item) in items.pos().enumerate() {
    block(
      width: 100%,
      inset: (left: 8pt, rest: 6pt),
      [
        #box(
          fill: teal,
          radius: 10pt,
          inset: (x: 7pt, y: 3pt),
          text(size: 8pt, weight: "bold", fill: white, str(i + 1))
        )
        #h(6pt)
        #text(weight: "bold", fill: navy, item.title)
        #if "detail" in item [ — #item.detail]
      ]
    )
  }
}

// --- Results Table ---
#let results-table(headers, ..rows, caption: none) = {
  let tbl = table(
    columns: headers.len(),
    fill: (_, row) => if row == 0 { navy } else if calc.odd(row) { ice } else { white },
    stroke: 0.5pt + light-gray,
    inset: 8pt,
    ..headers.map(h => text(fill: white, weight: "bold", size: 10pt, h)),
    ..rows.pos().flatten().map(cell => text(size: 10pt, cell)),
  )
  if caption != none {
    figure(kind: table, tbl, caption: caption)
  } else { tbl }
}

// --- Comparison Block ---
#let comparison(a-title, a-items, b-title, b-items) = {
  block(breakable: false, width: 100%, grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    block(
      width: 100%,
      inset: 12pt,
      fill: ice,
      radius: 4pt,
      stroke: 1pt + teal,
      [
        #text(weight: "bold", fill: teal, a-title) \
        #v(4pt)
        #for item in a-items [• #item \ ]
      ]
    ),
    block(
      width: 100%,
      inset: 12pt,
      fill: ice,
      radius: 4pt,
      stroke: 1pt + cyan,
      [
        #text(weight: "bold", fill: cyan, b-title) \
        #v(4pt)
        #for item in b-items [• #item \ ]
      ]
    ),
  ))
}

// --- Branded Table (general-purpose with header styling) ---
#let branded-table(headers, ..rows, caption: none, label: none) = {
  let tbl = table(
    columns: headers.len(),
    fill: (_, row) => if row == 0 { navy } else if calc.odd(row) { ice } else { white },
    stroke: 0.5pt + light-gray,
    inset: 8pt,
    align: (col, row) => if row == 0 { center } else { left },
    ..headers.map(h => text(fill: white, weight: "bold", size: 10pt, h)),
    ..rows.pos().flatten().map(cell => text(size: 10pt, cell)),
  )
  if caption != none {
    figure(kind: table, tbl, caption: caption)
  } else {
    tbl
  }
}

// --- Branded Figure (image with standard styling) ---
#let branded-figure(path, caption: none, width: 80%) = {
  figure(
    image(path, width: width),
    caption: if caption != none { caption } else { none },
  )
}

// --- Appendix Heading Reset ---
#let appendix() = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
}

// ============================================================
// DIAGRAM PRIMITIVES (pure Typst, no packages needed)
// Use these when fletcher/cetz packages are unavailable, or for
// simple flowcharts where full package power isn't needed.
// ============================================================

// A node box for flowchart-style diagrams
// Automatically uses white text on dark backgrounds (navy, blue)
#let flow-node(label, fill-color: ice, border-color: teal, width: 90pt) = {
  let text-color = if fill-color == navy or fill-color == blue or fill-color == rgb("#0B1E3D") or fill-color == rgb("#1A56DB") { white } else { navy }
  box(
    width: width,
    inset: (x: 8pt, y: 6pt),
    fill: fill-color,
    stroke: 1.5pt + border-color,
    radius: 5pt,
    align(center, text(size: 8pt, weight: "bold", fill: text-color, label))
  )
}

// A diamond (decision) node
#let flow-diamond(label, fill-color: rgb("#FEF3C7"), border-color: amber, width: 80pt) = {
  box(
    width: width,
    inset: (x: 6pt, y: 10pt),
    fill: fill-color,
    stroke: 1.5pt + border-color,
    radius: 0pt,
    align(center, text(size: 7.5pt, weight: "bold", fill: navy, label))
  )
}

// Arrow connectors
#let arrow-right(label: none) = {
  h(2pt)
  if label != none {
    stack(dir: ttb, spacing: 2pt,
      text(size: 7pt, fill: gray, label),
      text(size: 12pt, fill: navy)[#sym.arrow.r]
    )
  } else {
    text(size: 12pt, fill: navy)[#sym.arrow.r]
  }
  h(2pt)
}

#let arrow-down(label: none) = {
  v(1pt)
  if label != none {
    align(center, stack(dir: ltr, spacing: 4pt,
      text(size: 12pt, fill: navy)[#sym.arrow.b],
      text(size: 7pt, fill: gray, label),
    ))
  } else {
    align(center, text(size: 12pt, fill: navy)[#sym.arrow.b])
  }
  v(1pt)
}

// Horizontal flow: a row of nodes connected by arrows
#let flow-row(..items) = {
  let elems = items.pos()
  block(breakable: false, width: 100%, align(center, {
    for (i, item) in elems.enumerate() {
      item
      if i < elems.len() - 1 {
        arrow-right()
      }
    }
  }))
}

// A full flowchart container
#let flowchart(body) = {
  block(
    breakable: false,
    width: 100%,
    inset: 16pt,
    fill: white,
    stroke: 0.5pt + light-gray,
    radius: 4pt,
    align(center, body)
  )
}

// Horizontal bar chart using pure Typst
#let bar-chart(bars, max-value: auto, width: 100%) = {
  let actual-max = if max-value == auto {
    bars.fold(0, (acc, b) => calc.max(acc, b.value))
  } else { max-value }
  block(breakable: false, width: width, inset: 8pt, {
    for bar in bars {
      let pct = bar.value / actual-max * 100
      let bar-color = if "color" in bar { bar.color } else { teal }
      grid(
        columns: (80pt, 1fr, 40pt),
        gutter: 6pt,
        align(right, text(size: 8pt, weight: "bold", fill: navy, bar.label)),
        box(width: 100%, {
          box(
            width: pct * 1% * 100%,
            height: 16pt,
            fill: bar-color,
            radius: (right: 3pt),
          )
        }),
        align(left, text(size: 8pt, fill: gray, bar.display)),
      )
      v(4pt)
    }
  })
}

// Three-circle Venn diagram approximation
#let venn-three(a-label, b-label, c-label, center-label: none) = {
  block(breakable: false, width: 100%, inset: 12pt, align(center, {
    grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0pt,
      {
        grid.cell(colspan: 3, align(center, {
          box(width: 120pt, height: 60pt, fill: rgb("#DBEAFE80"), stroke: 1pt + blue, radius: 50%,
            align(center + horizon, text(size: 8pt, weight: "bold", fill: blue, a-label))
          )
        }))
      },
      align(right, box(width: 120pt, height: 60pt, fill: rgb("#D1FAE580"), stroke: 1pt + green, radius: 50%,
        align(center + horizon, text(size: 8pt, weight: "bold", fill: green, b-label))
      )),
      if center-label != none {
        align(center + horizon, text(size: 7pt, weight: "bold", fill: navy, center-label))
      },
      align(left, box(width: 120pt, height: 60pt, fill: rgb("#FCE7F380"), stroke: 1pt + rgb("#EC4899"), radius: 50%,
        align(center + horizon, text(size: 8pt, weight: "bold", fill: rgb("#EC4899"), c-label))
      )),
    )
  }))
}

// ============================================================
// PAGE SETUP FUNCTION — call this in your document
// ============================================================
#let branded-doc(
  title: "Document Title",
  subtitle: none,
  author: brand-name,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  category: none,
  version: none,
  doc-type: "guide",  // "guide", "report", "readme", "handout", "paper"
  body,
) = {
  // Page setup
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 8pt, fill: gray)
        grid(
          columns: (1fr, 1fr),
          align(left, [_#title _]),
          align(right, [#brand-slogan]),
        )
        v(4pt)
        line(length: 100%, stroke: 0.5pt + light-gray)
      }
    },
    footer: context {
      set text(size: 8pt, fill: gray)
      line(length: 100%, stroke: 0.5pt + light-gray)
      v(4pt)
      grid(
        columns: (1fr, 1fr),
        align(left, [Created by Isham Rashik]),
        align(right, [Page #counter(page).display("1 / 1", both: true)]),
      )
    },
  )

  // Typography
  set text(font: "sans-serif", size: 12pt, fill: navy)
  set par(justify: true, leading: 0.9em)
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  show heading.where(level: 1): it => {
    v(16pt)
    text(size: 20pt, weight: "bold", fill: navy, it)
    v(2pt)
    line(length: 100%, stroke: 2pt + teal)
    v(8pt)
  }

  show heading.where(level: 2): it => {
    v(12pt)
    text(size: 15pt, weight: "bold", fill: navy, it)
    v(4pt)
  }

  show heading.where(level: 3): it => {
    v(8pt)
    text(size: 12pt, weight: "bold", fill: teal, it)
    v(2pt)
  }

  // Inline code
  show raw.where(block: false): box.with(
    fill: ice,
    inset: (x: 4pt, y: 2pt),
    outset: (y: 2pt),
    radius: 2pt,
  )

  // Code blocks
  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: navy,
      radius: 4pt,
      inset: 12pt,
      text(font: "monospace", size: 9pt, fill: mist, it)
    )
  }

  // Links
  show link: it => text(fill: blue, it)

  // Table captions go on TOP, figure/code captions go on BOTTOM
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => {
    text(size: 10pt, fill: gray, {
      text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering):]
      [ ]
      it.body
    })
  }

  // --- Title Page ---
  {
    set page(header: none, footer: none)

    v(1fr)

    if category != none {
      badge(category)
      v(8pt)
    }

    text(size: 28pt, weight: "bold", fill: navy, title)

    if subtitle != none {
      v(4pt)
      text(size: 15pt, fill: teal, subtitle)
    }

    v(16pt)
    line(length: 60%, stroke: 2pt + teal)
    v(16pt)

    text(size: 12pt, fill: navy)[
      *#author* · #brand-title \
      #brand-slogan \
      #brand-descriptor
    ]

    v(8pt)

    set text(size: 9pt, fill: gray)
    if version != none [Version: #version · ]
    [#date]

    v(1fr)

    // Personal links removed per user request

    pagebreak()
  }

  // --- Document Body ---
  body
}
