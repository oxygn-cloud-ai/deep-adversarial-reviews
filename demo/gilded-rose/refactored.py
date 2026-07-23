# -*- coding: utf-8 -*-
"""
Gilded Rose inventory system.

Business rules (GildedRoseRequirements.md):
- All items have SellIn (days to sell) and Quality (how valuable).
- Each day SellIn decreases by 1 (except Sulfuras).
- Normal items: Quality -1/day; -2 after sell-by. Minimum 0.
- Aged Brie: Quality +1/day; +2 after sell-by. Maximum 50.
- Sulfuras: Legendary. Quality always 80, never changes, no sell-by.
- Backstage passes: +1 normally; +2 when <=10 days; +3 when <=5 days;
  drops to 0 after concert (sell-by < 0). Maximum 50.
- Conjured items: degrade twice as fast (-2/day; -4 after sell-by).
  Detected by name containing "Conjured" (case-insensitive). Minimum 0.

IMPORTANT: The Item class definition must not be modified (goblin rule).
All item classification is done via name string matching.
"""

from typing import List

# ── Item class (DO NOT MODIFY) ──
class Item:
    def __init__(self, name: str, sell_in: int, quality: int):
        self.name = name
        self.sell_in = sell_in
        self.quality = quality

    def __repr__(self) -> str:
        return f"Item(name={self.name!r}, sell_in={self.sell_in}, quality={self.quality})"


# ── Named constants ──
SULFURAS = "Sulfuras, Hand of Ragnaros"
AGED_BRIE = "Aged Brie"
BACKSTAGE = "Backstage passes to a TAFKAL80ETC concert"

MIN_QUALITY = 0
MAX_QUALITY = 50
SULFURAS_QUALITY = 80
BACKSTAGE_DOUBLE_DAYS = 10
BACKSTAGE_TRIPLE_DAYS = 5


# ── Quality helpers ──
def _increase_quality(item: Item, amount: int = 1) -> None:
    item.quality = min(MAX_QUALITY, item.quality + amount)


def _decrease_quality(item: Item, amount: int = 1) -> None:
    item.quality = max(MIN_QUALITY, item.quality - amount)


# ── Item classification ──
def _is_sulfuras(item: Item) -> bool:
    return item.name == SULFURAS


def _is_aged_brie(item: Item) -> bool:
    return item.name == AGED_BRIE


def _is_backstage_pass(item: Item) -> bool:
    return item.name == BACKSTAGE


def _is_conjured(item: Item) -> bool:
    return "conjured" in item.name.lower()


# ── Update strategies ──
def _update_sulfuras(item: Item) -> None:
    item.quality = SULFURAS_QUALITY


def _update_aged_brie(item: Item) -> None:
    item.sell_in -= 1
    rate = 2 if item.sell_in < 0 else 1
    _increase_quality(item, rate)


def _update_backstage_pass(item: Item) -> None:
    item.sell_in -= 1
    if item.sell_in < 0:
        item.quality = MIN_QUALITY
    elif item.sell_in < BACKSTAGE_TRIPLE_DAYS:
        _increase_quality(item, 3)
    elif item.sell_in < BACKSTAGE_DOUBLE_DAYS:
        _increase_quality(item, 2)
    else:
        _increase_quality(item, 1)


def _update_conjured(item: Item) -> None:
    item.sell_in -= 1
    rate = 4 if item.sell_in < 0 else 2
    _decrease_quality(item, rate)


def _update_normal(item: Item) -> None:
    item.sell_in -= 1
    rate = 2 if item.sell_in < 0 else 1
    _decrease_quality(item, rate)


# ── Dispatcher ──
_STRATEGIES = [
    (_is_sulfuras, _update_sulfuras),
    (_is_aged_brie, _update_aged_brie),
    (_is_backstage_pass, _update_backstage_pass),
    (_is_conjured, _update_conjured),
]


def _get_strategy(item: Item):
    for predicate, strategy in _STRATEGIES:
        if predicate(item):
            return strategy
    return None


# ── GildedRose ──
class GildedRose:
    """Manages inventory and updates quality daily."""

    def __init__(self, items: List[Item]) -> None:
        self.items = items

    def update_quality(self) -> None:
        """Update every item's quality and sell_in for one day."""
        for item in self.items:
            strategy = _get_strategy(item)
            if strategy is not None:
                strategy(item)
            else:
                _update_normal(item)
