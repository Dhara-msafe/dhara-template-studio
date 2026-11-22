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
    pdf.multi_cell(0, 10, title)
    pdf.ln(4)
    pdf.set_font("Helvetica", size=12)
    for line in body.split("\n"):
        pdf.multi_cell(0, 7, line)
    return bytes(pdf.output())


def render_docx(title: str, body: str) -> bytes:
    doc = Document()
    doc.add_heading(title, level=1)
    for line in body.split("\n"):
        doc.add_paragraph(line)
    buf = io.BytesIO()
    doc.save(buf)
    return buf.getvalue()
