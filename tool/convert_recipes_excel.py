#!/usr/bin/env python3
"""Convert luqma_haneya_100_detailed_recipes.xlsx → assets/recipes.json."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import openpyxl

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_XLSX = Path.home() / "Downloads" / "luqma_haneya_100_detailed_recipes.xlsx"
OUT = ROOT / "assets" / "recipes.json"

WEAK_ID_EXACT = {
    "tea_mint",
    "milk_banana",
    "dates_milk",
    "cheese_sandwich",
}

WEAK_TITLE_PATTERNS = [
    re.compile(r"شاي", re.I),
    re.compile(r"موز\s*باللبن", re.I),
    re.compile(r"تمر\s*باللبن", re.I),
    re.compile(r"ساندوتش\s*جب", re.I),
    re.compile(r"جبن\s*ساند", re.I),
]


def split_lines(value) -> list[str]:
    if value is None:
        return []
    text = str(value).strip()
    if not text:
        return []
    return [line.strip() for line in re.split(r"[\r\n]+", text) if line.strip()]


def split_numbered_steps(value) -> list[str]:
    if value is None:
        return []
    text = str(value).strip()
    if not text:
        return []
    parts = re.split(r"\n(?=\d+\.\s)", text)
    steps: list[str] = []
    for part in parts:
        part = part.strip()
        part = re.sub(r"^\d+\.\s*", "", part).strip()
        if part:
            steps.append(part)
    return steps


def split_bullets(value) -> list[str]:
    lines = split_lines(value)
    out: list[str] = []
    for line in lines:
        line = re.sub(r"^[-•]\s*", "", line).strip()
        if line:
            out.append(line)
    return out


def as_bool(value) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    return str(value).strip().lower() in {"1", "true", "yes", "y"}


def is_weak(recipe: dict) -> bool:
    rid = str(recipe["id"]).lower()
    if rid in WEAK_ID_EXACT:
        return True
    title = recipe["title"]
    for pat in WEAK_TITLE_PATTERNS:
        if pat.search(title):
            return True
    return False


def row_to_recipe(row: tuple) -> dict | None:
    if not row[0]:
        return None
    recipe = {
        "id": str(row[0]).strip(),
        "title": str(row[1] or "").strip(),
        "description": str(row[2] or "").strip(),
        "minutes": int(row[3] or 30),
        "servings": int(row[4] or 4),
        "tags": split_lines(row[5]),
        "mainIngredients": split_lines(row[6]),
        "optionalIngredients": split_lines(row[7]),
        "steps": split_numbered_steps(row[8]),
        "mealType": str(row[9] or "any").strip(),
        "difficulty": str(row[10] or "medium").strip(),
        "budget": str(row[11] or "medium").strip(),
        "spicy": as_bool(row[12]),
        "cuisine": str(row[13] or "mixed").strip(),
        "chefTips": split_bullets(row[14]),
        "servingSuggestions": split_bullets(row[15]),
    }
    if not recipe["id"] or not recipe["title"]:
        return None
    if not recipe["steps"]:
        return None
    if not recipe["mainIngredients"]:
        return None
    return recipe


def validate_recipes(recipes: list[dict]) -> None:
    ids = set()
    for i, r in enumerate(recipes):
        rid = r["id"]
        if rid in ids:
            raise ValueError(f"duplicate id: {rid}")
        ids.add(rid)
        for key in (
            "tags",
            "mainIngredients",
            "optionalIngredients",
            "steps",
            "chefTips",
            "servingSuggestions",
        ):
            val = r[key]
            if not isinstance(val, list) or not all(isinstance(x, str) for x in val):
                raise ValueError(f"{rid}: {key} must be list[str]")
        if not isinstance(r["minutes"], int) or r["minutes"] <= 0:
            raise ValueError(f"{rid}: invalid minutes")
        if not isinstance(r["servings"], int) or r["servings"] <= 0:
            raise ValueError(f"{rid}: invalid servings")


def main() -> int:
    xlsx = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_XLSX
    if not xlsx.is_file():
        print(f"Missing Excel file: {xlsx}", file=sys.stderr)
        return 1

    wb = openpyxl.load_workbook(xlsx, read_only=True, data_only=True)
    ws = wb.active
    recipes: list[dict] = []
    skipped: list[str] = []

    for row in ws.iter_rows(min_row=2, values_only=True):
        recipe = row_to_recipe(row)
        if recipe is None:
            continue
        if is_weak(recipe):
            skipped.append(recipe["id"])
            continue
        recipes.append(recipe)

    validate_recipes(recipes)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(recipes, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(recipes)} recipes → {OUT}")
    if skipped:
        print(f"Skipped weak recipes: {', '.join(skipped)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
