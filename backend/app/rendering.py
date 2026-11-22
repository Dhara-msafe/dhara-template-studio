"""Turns a template version's content + a draft's filled-in field values into
a downloadable document. Deliberately simple for the MVP: `{{field_key}}`
placeholders in the version's `content.body` get substituted, matching the
same substitution the Fill & Preview page's build notes describe doing
client-side for the live preview ("client-side placeholder substitution").
Swap this for a real templating/formatting engine once real legal content
(TS-11) replaces the seed placeholder text.
"""

import io
import re

from docx import Document
from fpdf import FPDF
from fpdf.enums import XPos, YPos


def render_body(content: dict, fields: dict) -> str:
    body = content.get("body", "")

    def replace(match: re.Match) -> str:
        key = match.group(1).strip()
        return str(fields.get(key, f"[{key}]"))

    return re.sub(r"\{\{\s*([\w.]+)\s*\}\}", replace, body)


def render_pdf(title: str, body: str) -> bytes:
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 16)
    # multi_cell's default new_x/new_y leaves the cursor at the END of the
    # text, not back at the left margin. With width=0 ("use remaining page
    # width from the current x"), every following multi_cell(0, ...) call
    # then has LESS width than the last, and a few calls in it hits zero
    # and raises "not enough horizontal space to render a single
    # character" — on completely ordinary text. Forcing new_x=LMARGIN,
    # new_y=NEXT on every call is what actually resets the cursor.
    pdf.multi_cell(0, 10, title, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(4)
    pdf.set_font("Helvetica", size=12)
    for line in body.split("\n"):
        # multi_cell also raises on an empty string ("not enough
        # horizontal space") — paragraph breaks in real content (blank
        # lines between clauses) hit this constantly, so blank lines get
        # a plain line-advance instead.
        if line.strip():
            pdf.multi_cell(0, 7, line, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        else:
            pdf.ln(7)
    return bytes(pdf.output())


def render_docx(title: str, body: str) -> bytes:
    doc = Document()
    doc.add_heading(title, level=1)
    for line in body.split("\n"):
        doc.add_paragraph(line)
    buf = io.BytesIO()
    doc.save(buf)
    return buf.getvalue()
